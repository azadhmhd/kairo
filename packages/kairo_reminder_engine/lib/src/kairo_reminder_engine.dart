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
    required KairoScheduler scheduler,
    required KairoWorkflowEngine workflowEngine,
    required KairoEventBus eventBus,
  })  : _reminders = reminders,
        _settings = settings,
        _scheduler = scheduler,
        _workflowEngine = workflowEngine,
        _eventBus = eventBus;

  /// How long an unanswered reminder waits before asking again.
  ///
  /// A reminder the user walked away from is not the same as one they turned
  /// down, so it keeps asking rather than waiting out its whole interval.
  static const Duration nagInterval = Duration(minutes: 1);

  final ReminderRepository _reminders;
  final SettingsRepository _settings;
  final KairoScheduler _scheduler;
  final KairoWorkflowEngine _workflowEngine;
  final KairoEventBus _eventBus;

  final Map<String, ReminderDefinition> _definitions =
      <String, ReminderDefinition>{};

  /// The reminder each definition is still waiting on an answer for.
  final Map<String, ReminderOccurrence> _unanswered =
      <String, ReminderOccurrence>{};

  /// The schedule ids this engine put in the scheduler. Tracked so turning a
  /// reminder off removes its schedule and nothing else — the scheduler is
  /// shared with whatever else comes to use it.
  final Set<String> _scheduled = <String>{};

  UserSettings _currentSettings = UserSettings.defaults;

  StreamSubscription<List<ReminderDefinition>>? _definitionsSubscription;
  StreamSubscription<UserSettings>? _settingsSubscription;
  StreamSubscription<ReminderAnsweredEvent>? _answeredSubscription;

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
  }

  /// Stops following the database and removes the schedules this engine added.
  Future<void> dispose() async {
    await _definitionsSubscription?.cancel();
    await _settingsSubscription?.cancel();
    await _answeredSubscription?.cancel();
    _definitionsSubscription = null;
    _settingsSubscription = null;
    _answeredSubscription = null;

    for (final String id in _scheduled) {
      _scheduler.remove(id);
    }
    _scheduled.clear();
    _definitions.clear();
    _unanswered.clear();
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

  /// Records the reminder and announces it.
  ///
  /// A reminder still waiting for an answer is asked again rather than started
  /// over, and the next asking is [nagInterval] away instead of a whole
  /// interval. A second occurrence would mark the first missed and count one
  /// reminder as two, so the user's history would degrade the longer they took
  /// to answer.
  Future<void> _announce(ScheduleDueEvent event) async {
    final ReminderDefinition? definition = _definitions[event.scheduleId];
    if (definition == null) {
      return;
    }

    ReminderOccurrence? occurrence = _unanswered[definition.id];
    if (occurrence == null) {
      // Anything still unanswered has been overtaken by this one, and would
      // otherwise stay pending forever.
      await _reminders.expirePending(definition.id, event.dueAt);

      occurrence = ReminderOccurrence(
        // Derived rather than random: a reminder cannot come due twice at the
        // same instant, and this id is readable in the database.
        id: '${definition.id}@${event.dueAt.toIso8601String()}',
        definitionId: definition.id,
        dueAt: event.dueAt,
      );
      await _reminders.recordDue(occurrence);
      _unanswered[definition.id] = occurrence;
    }

    // Measured from now rather than from [event.dueAt], which is already in the
    // past and can be hours stale after the machine has slept. Nagging from
    // there would spend a tick catching up for every minute of lag.
    _scheduler.rescheduleTo(definition.id, DateTime.now().add(nagInterval));
    _eventBus.publish(
      ReminderDueEvent(definition: definition, occurrence: occurrence),
    );
  }

  /// Puts a reminder back on its usual rhythm once it has been answered.
  ///
  /// Snoozing is left alone: `ReminderService` sets that firing itself, and the
  /// bus delivers this after it has, so rescheduling here would overwrite the
  /// snooze with a full interval.
  void _onAnswered(ReminderAnsweredEvent event) {
    final String definitionId = event.occurrence.definitionId;
    if (_unanswered[definitionId]?.id != event.occurrence.id) {
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
    _unanswered.removeWhere(
      (String id, ReminderOccurrence _) => !wanted.contains(id),
    );

    _scheduled
      ..clear()
      ..addAll(wanted);
  }
}

/// The application's [KairoReminderEngine].
final Provider<KairoReminderEngine> reminderEngineProvider =
    Provider<KairoReminderEngine>(
  (Ref ref) {
    final KairoReminderEngine engine = KairoReminderEngine(
      reminders: ref.watch(reminderRepositoryProvider),
      settings: ref.watch(settingsRepositoryProvider),
      scheduler: ref.watch(schedulerProvider),
      workflowEngine: ref.watch(workflowEngineProvider),
      eventBus: ref.watch(eventBusProvider),
    );
    ref.onDispose(engine.dispose);
    return engine;
  },
);
