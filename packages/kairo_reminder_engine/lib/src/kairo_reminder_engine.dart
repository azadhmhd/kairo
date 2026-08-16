import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo_event_bus/event_bus.dart';
import 'package:kairo_scheduler/scheduler.dart';
import 'package:kairo_shared_models/shared_models.dart';
import 'package:kairo_storage/storage.dart';
import 'package:kairo_workflow_engine/workflow_engine.dart';

import 'default_reminders.dart';
import 'reminder_events.dart';

/// Turns the user's reminders into schedules, and schedules into reminders.
///
/// Owns *what* a reminder is. When one is due belongs to the scheduler, and
/// whether it may be shown belongs to the workflow this registers.
///
/// Definitions and settings are held in memory, refreshed from the database as
/// they change, because workflow conditions must answer synchronously.
class KairoReminderEngine {
  /// Creates an engine wiring the given services together.
  KairoReminderEngine({
    required ReminderRepository reminders,
    required SettingsRepository settings,
    required CoachRepository coach,
    required KairoScheduler scheduler,
    required KairoWorkflowEngine workflowEngine,
    required KairoEventBus eventBus,
  })  : _reminders = reminders,
        _settings = settings,
        _coach = coach,
        _scheduler = scheduler,
        _workflowEngine = workflowEngine,
        _eventBus = eventBus;

  /// How long an unanswered reminder waits before asking again.
  static const Duration nagInterval = Duration(minutes: 1);

  /// How many times one firing is asked about before it is recorded as missed.
  static const int maxAsks = 5;

  final ReminderRepository _reminders;
  final SettingsRepository _settings;
  final CoachRepository _coach;
  final KairoScheduler _scheduler;
  final KairoWorkflowEngine _workflowEngine;
  final KairoEventBus _eventBus;

  final Map<String, ReminderDefinition> _definitions =
      <String, ReminderDefinition>{};

  /// The firing each reminder is still waiting on an answer for.
  final Map<String, _Asking> _unanswered = <String, _Asking>{};

  /// The coach's wording, by reminder id, for the reminders that have any.
  final Map<String, String> _coachLines = <String, String>{};

  /// The schedule ids this engine put in the scheduler. Tracked so turning a
  /// reminder off removes its schedule and nothing else — the scheduler is
  /// shared with whatever else comes to use it.
  final Set<String> _scheduled = <String>{};

  UserSettings _currentSettings = UserSettings.defaults;

  StreamSubscription<List<ReminderDefinition>>? _definitionsSubscription;
  StreamSubscription<UserSettings>? _settingsSubscription;
  StreamSubscription<ReminderAnsweredEvent>? _answeredSubscription;
  StreamSubscription<Map<String, String>>? _coachSubscription;

  /// The user's reminders as this engine last saw them.
  Iterable<ReminderDefinition> get definitions => _definitions.values;

  /// Seeds the default reminders, then starts keeping schedules in step with
  /// them.
  ///
  /// Safe to call on every launch: seeding skips anything already there, so the
  /// user's own edits survive.
  Future<void> start() async {
    for (final ReminderDefinition reminder in defaultReminders) {
      await _reminders.insertIfAbsent(reminder);
    }

    _currentSettings = await _settings.read();
    _settingsSubscription = _settings.watch().listen(
          (UserSettings settings) => _currentSettings = settings,
        );

    _workflowEngine.register(_dueWorkflow());
    _answeredSubscription =
        _eventBus.on<ReminderAnsweredEvent>().listen(_onAnswered);
    _definitionsSubscription =
        _reminders.watchDefinitions().listen(_syncSchedules);

    _coachSubscription = _coach.watchMessages().listen(
      (Map<String, String> lines) {
        _coachLines
          ..clear()
          ..addAll(lines);
      },
    );
  }

  /// Stops following the database and removes the schedules this engine added.
  Future<void> dispose() async {
    await _definitionsSubscription?.cancel();
    await _settingsSubscription?.cancel();
    await _answeredSubscription?.cancel();
    await _coachSubscription?.cancel();
    _definitionsSubscription = null;
    _settingsSubscription = null;
    _answeredSubscription = null;
    _coachSubscription = null;

    for (final String id in _scheduled) {
      _scheduler.remove(id);
    }
    _scheduled.clear();
    _definitions.clear();
    _unanswered.clear();
    _coachLines.clear();
  }

  /// The rule that turns a schedule coming due into a reminder being shown.
  Workflow<ScheduleDueEvent> _dueWorkflow() {
    return Workflow<ScheduleDueEvent>(
      name: 'show a reminder when its schedule is due',
      when: <WorkflowCondition<ScheduleDueEvent>>[
        _isAnEnabledReminder,
        _isWithinItsActiveHours,
        _isNotDuringQuietHours,
      ],
      then: <WorkflowAction<ScheduleDueEvent>>[_announce],
    );
  }

  /// Whether this schedule belongs to a reminder that is switched on. Also what
  /// keeps the engine from reacting to schedules it did not create.
  bool _isAnEnabledReminder(ScheduleDueEvent event) =>
      _definitions[event.scheduleId]?.enabled ?? false;

  /// Whether the reminder is allowed to fire at this hour of the day.
  bool _isWithinItsActiveHours(ScheduleDueEvent event) {
    final DailyWindow? active = _definitions[event.scheduleId]?.activeHours;
    return active == null || active.contains(event.dueAt);
  }

  /// Whether the user has asked for silence right now. Applies to every
  /// reminder regardless of its own active hours.
  bool _isNotDuringQuietHours(ScheduleDueEvent event) =>
      !_currentSettings.isQuietAt(event.dueAt);

  /// A firing still waiting for an answer is asked again rather than started
  /// over, which would mark the first missed and count one reminder as several.
  Future<void> _announce(ScheduleDueEvent event) async {
    final ReminderDefinition? definition = _definitions[event.scheduleId];
    if (definition == null) {
      return;
    }

    final _Asking? asking = _unanswered[definition.id];

    // Asked enough. Recorded as ignored and left until its next turn, so the
    // history says what happened instead of staying pending forever.
    if (asking != null && asking.asks >= maxAsks) {
      await _reminders.expirePending(definition.id, event.dueAt);
      _unanswered.remove(definition.id);
      return;
    }

    final ReminderOccurrence occurrence;
    if (asking != null) {
      asking.asks++;
      occurrence = asking.occurrence;
    } else {
      await _reminders.expirePending(definition.id, event.dueAt);
      occurrence = ReminderOccurrence(
        // Derived rather than random: a reminder cannot come due twice at the
        // same instant, and this id is readable in the database.
        id: '${definition.id}@${event.dueAt.toIso8601String()}',
        definitionId: definition.id,
        dueAt: event.dueAt,
      );
      await _reminders.recordDue(occurrence);
      _unanswered[definition.id] = _Asking(occurrence);
    }

    // From now, not from [event.dueAt], which can be hours stale after the
    // machine has slept: nagging from there spends a tick per minute of lag.
    _scheduler.rescheduleTo(definition.id, DateTime.now().add(nagInterval));
    _eventBus.publish(
      ReminderDueEvent(definition: _worded(definition), occurrence: occurrence),
    );
  }

  /// The reminder as it should be said now: the coach's line if there is one,
  /// standing in front of the user's own label, which is never overwritten.
  ReminderDefinition _worded(ReminderDefinition definition) {
    final String? coached = _coachLines[definition.id];
    return coached == null ? definition : definition.copyWith(label: coached);
  }

  /// Puts a reminder back on its usual rhythm once it has been answered.
  ///
  /// Snoozing is skipped: `ReminderService` sets that one, after this runs.
  void _onAnswered(ReminderAnsweredEvent event) {
    final String definitionId = event.occurrence.definitionId;
    if (_unanswered[definitionId]?.occurrence.id != event.occurrence.id) {
      return;
    }
    _unanswered.remove(definitionId);

    final ReminderDefinition? definition = _definitions[definitionId];
    if (definition == null || event.outcome == ReminderOutcome.snoozed) {
      return;
    }

    _scheduler.rescheduleTo(
      definitionId,
      (event.occurrence.respondedAt ?? event.occurrence.dueAt)
          .add(definition.interval),
    );
  }

  /// Brings the scheduler in line with [definitions].
  ///
  /// Schedules that are already correct are left alone: adding one restarts its
  /// countdown, so editing one reminder's label must not push every other
  /// reminder's next firing into the future.
  void _syncSchedules(List<ReminderDefinition> definitions) {
    _definitions
      ..clear()
      ..addEntries(
        definitions.map(
          (ReminderDefinition d) => MapEntry<String, ReminderDefinition>(d.id, d),
        ),
      );

    final Set<String> wanted = <String>{};

    for (final ReminderDefinition definition in definitions) {
      if (!definition.enabled) {
        continue;
      }
      wanted.add(definition.id);

      final KairoSchedule schedule =
          KairoSchedule.every(definition.id, definition.interval);
      if (_scheduler.scheduleFor(definition.id) != schedule) {
        _scheduler.add(schedule);
      }
    }

    for (final String id in _scheduled.difference(wanted)) {
      _scheduler.remove(id);
    }

    // A reminder switched off or deleted mid-question stops being asked about.
    _unanswered.removeWhere((String id, _Asking _) => !wanted.contains(id));

    _scheduled
      ..clear()
      ..addAll(wanted);
  }
}

/// One firing waiting for an answer, and how many times it has been asked.
class _Asking {
  _Asking(this.occurrence);

  final ReminderOccurrence occurrence;
  int asks = 1;
}

/// The application's [KairoReminderEngine].
final Provider<KairoReminderEngine> reminderEngineProvider =
    Provider<KairoReminderEngine>(
  (Ref ref) {
    final KairoReminderEngine engine = KairoReminderEngine(
      reminders: ref.watch(reminderRepositoryProvider),
      settings: ref.watch(settingsRepositoryProvider),
      coach: ref.watch(coachRepositoryProvider),
      scheduler: ref.watch(schedulerProvider),
      workflowEngine: ref.watch(workflowEngineProvider),
      eventBus: ref.watch(eventBusProvider),
    );
    ref.onDispose(engine.dispose);
    return engine;
  },
);
