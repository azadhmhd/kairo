import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo_event_bus/event_bus.dart';
import 'package:kairo_reminder_engine/reminder_engine.dart';
import 'package:kairo_scheduler/scheduler.dart';
import 'package:kairo_shared_models/shared_models.dart';
import 'package:kairo_storage/storage.dart';

import 'coach_events.dart';
import 'coach_prompt.dart';
import 'kairo_ai_client.dart';

/// Watches how the user's reminders are going, and rewords the ones that are
/// not working. Nothing here is on the path to the user seeing a reminder.
class KairoCoach {
  KairoCoach({
    required ReminderRepository reminders,
    required CoachRepository coach,
    required ReminderStatsRepository stats,
    required SettingsRepository settings,
    required KairoScheduler scheduler,
    required KairoEventBus eventBus,
    KairoAiClient client = const KairoAiClient(),
  })  : _reminders = reminders,
        _coach = coach,
        _stats = stats,
        _settings = settings,
        _scheduler = scheduler,
        _eventBus = eventBus,
        _client = client;

  static const String wrapUpScheduleId = 'kairo-coach-wrap-up';

  static const int _historyDepth = 8;

  static const int _minimumHistory = 4;

  static const double _slippingAtOrBelow = 0.3;

  static const double _thrivingAtOrAbove = 0.6;

  /// How long a line stands before it is written again for the same stance.
  static const Duration _refreshAfter = Duration(days: 1);

  static const int _wrapUpLeadMinutes = 5;

  static const int _reactionAlternatives = 4;

  static const int _reactionTokens = 200;

  static const int _reactionCharacters = 400;

  final ReminderRepository _reminders;
  final CoachRepository _coach;
  final ReminderStatsRepository _stats;
  final SettingsRepository _settings;
  final KairoScheduler _scheduler;
  final KairoEventBus _eventBus;
  final KairoAiClient _client;

  UserSettings _current = UserSettings.defaults;

  /// The reminders being reworded right now, so a nagging reminder cannot put
  /// the same request in flight several times over.
  final Set<String> _rewording = <String>{};

  final Set<ReminderOutcome> _reacting = <ReminderOutcome>{};

  StreamSubscription<UserSettings>? _settingsSubscription;
  StreamSubscription<ReminderDueEvent>? _dueSubscription;
  StreamSubscription<ReminderAnsweredEvent>? _answeredSubscription;
  StreamSubscription<ScheduleDueEvent>? _scheduleSubscription;

  /// Starts watching. With nothing configured this listens and does nothing.
  Future<void> start() async {
    _current = await _settings.read();
    _syncWrapUp();

    _settingsSubscription = _settings.watch().listen(_onSettingsChanged);

    // Both directions of the same question: an arriving reminder is what an
    // ignored one looks like, an answer is what a kept one looks like.
    _dueSubscription = _eventBus.on<ReminderDueEvent>().listen(
          (ReminderDueEvent event) => _consider(event.occurrence.definitionId),
        );
    _answeredSubscription = _eventBus.on<ReminderAnsweredEvent>().listen(
      (ReminderAnsweredEvent event) {
        _consider(event.occurrence.definitionId);
        unawaited(
          _guarded('rewriting a reaction', () => _reactTo(event.outcome)),
        );
      },
    );

    _scheduleSubscription =
        _eventBus.on<ScheduleDueEvent>().listen((ScheduleDueEvent event) {
      if (event.scheduleId == wrapUpScheduleId) {
        unawaited(_guarded('saying goodnight', _wrapUp));
      }
    });
  }

  Future<void> dispose() async {
    await _settingsSubscription?.cancel();
    await _dueSubscription?.cancel();
    await _answeredSubscription?.cancel();
    await _scheduleSubscription?.cancel();
    _settingsSubscription = null;
    _dueSubscription = null;
    _answeredSubscription = null;
    _scheduleSubscription = null;

    _scheduler.remove(wrapUpScheduleId);
    _rewording.clear();
    _reacting.clear();
  }

  /// Follows the user's settings, putting their own words back everywhere when
  /// they switch coaching off.
  void _onSettingsChanged(UserSettings settings) {
    final bool was = _current.ai.isUsable;
    _current = settings;
    _syncWrapUp();

    if (was && !settings.ai.isUsable) {
      unawaited(_guarded('putting your own words back', _coach.clearAll));
    }
  }

  void _consider(String definitionId) {
    unawaited(_guarded('rewording a reminder', () => _reword(definitionId)));
  }

  Future<void> _reword(String definitionId) async {
    if (!_current.ai.isUsable) {
      return;
    }
    if (!_rewording.add(definitionId)) {
      return;
    }

    try {
      final List<ReminderOutcome> recent = await _reminders.recentOutcomes(
        definitionId,
        limit: _historyDepth,
      );
      if (recent.length < _minimumHistory) {
        return;
      }

      final int completed = recent
          .where((ReminderOutcome o) => o == ReminderOutcome.completed)
          .length;
      final CoachStance? stance = _stanceFor(completed / recent.length);
      final CoachLine? existing = await _coach.line(definitionId);

      if (stance == null) {
        if (existing != null) {
          await _coach.clear(definitionId);
        }
        return;
      }

      final bool unchanged = existing != null &&
          existing.stance == stance &&
          DateTime.now().difference(existing.generatedAt) < _refreshAfter;
      if (unchanged) {
        return;
      }

      final ReminderDefinition? definition =
          await _reminders.definition(definitionId);
      if (definition == null) {
        return;
      }

      final String message = await _client.complete(
        settings: _current.ai,
        system: coachSystemPrompt,
        prompt: nudgePrompt(
          definition: definition,
          stance: stance,
          completed: completed,
          of: recent.length,
        ),
      );

      await _coach.write(
        CoachLine(
          definitionId: definitionId,
          message: message,
          stance: stance,
          generatedAt: DateTime.now(),
        ),
      );
    } finally {
      _rewording.remove(definitionId);
    }
  }

  Future<void> _reactTo(ReminderOutcome outcome) async {
    if (!_current.ai.isUsable || !_reacting.add(outcome)) {
      return;
    }

    try {
      final DateTime? writtenAt = await _coach.reactionsWrittenAt(outcome);
      if (writtenAt != null &&
          DateTime.now().difference(writtenAt) < _refreshAfter) {
        return;
      }

      final DateTime now = DateTime.now();
      final List<DailyTally> week = await _stats.dailyTallies(
        from: DateTime(now.year, now.month, now.day - 6),
        to: DateTime(now.year, now.month, now.day + 1),
      );

      int total(int Function(DailyTally) of) =>
          week.fold(0, (int sum, DailyTally d) => sum + of(d));

      final String reply = await _client.complete(
        settings: _current.ai,
        system: coachSystemPrompt,
        prompt: reactionsPrompt(
          outcome: outcome,
          completed: total((DailyTally d) => d.completed),
          missed: total((DailyTally d) => d.missed),
          dismissed: total((DailyTally d) => d.dismissed),
          snoozed: total((DailyTally d) => d.snoozed),
          streak: currentStreak(week, today: now),
          alternatives: _reactionAlternatives,
        ),
        maxTokens: _reactionTokens,
        maxCharacters: _reactionCharacters,
      );

      final List<String> lines = reply
          .split(reactionSeparator)
          .map((String line) => line.trim())
          .where((String line) => line.isNotEmpty && line.length <= 80)
          .toList();

      if (lines.isNotEmpty) {
        await _coach.replaceReactions(outcome, lines, DateTime.now());
      }
    } finally {
      _reacting.remove(outcome);
    }
  }

  Future<void> _wrapUp() async {
    if (!_current.ai.isUsable) {
      return;
    }

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final List<DailyTally> tallies = await _stats.dailyTallies(
      from: DateTime(today.year, today.month, today.day - 30),
      to: DateTime(today.year, today.month, today.day + 1),
    );

    DailyTally? todays;
    for (final DailyTally tally in tallies) {
      if (tally.day.year == today.year &&
          tally.day.month == today.month &&
          tally.day.day == today.day) {
        todays = tally;
      }
    }

    if (todays == null || todays.due == 0) {
      return;
    }

    final String line = await _client.complete(
      settings: _current.ai,
      system: coachSystemPrompt,
      prompt: wrapUpPrompt(
        completed: todays.completed,
        due: todays.due,
        streak: currentStreak(tallies, today: now),
      ),
    );

    _eventBus.publish(CoachSpokeEvent(line));
  }

  void _syncWrapUp() {
    final DailyWindow? quiet = _current.quietHours;
    if (quiet == null || !_current.ai.isUsable) {
      _scheduler.remove(wrapUpScheduleId);
      return;
    }

    // Wraps: quiet hours starting at 00:02 put the goodnight at 23:57 the
    // evening before, not at minute -3.
    final int minute =
        (quiet.from - _wrapUpLeadMinutes + DailyWindow.minutesPerDay) %
            DailyWindow.minutesPerDay;

    final KairoSchedule schedule =
        KairoSchedule.dailyAt(wrapUpScheduleId, minute);
    if (_scheduler.scheduleFor(wrapUpScheduleId) != schedule) {
      _scheduler.add(schedule);
    }
  }

  /// What [rate] of completed reminders says about a habit, or null when it
  /// says nothing in particular.
  static CoachStance? _stanceFor(double rate) {
    if (rate <= _slippingAtOrBelow) {
      return CoachStance.slipping;
    }
    if (rate >= _thrivingAtOrAbove) {
      return CoachStance.thriving;
    }
    return null;
  }

  /// Runs [work], swallowing anything it throws. Every path into the coach
  /// comes through here, which is what makes it a plugin rather than a part.
  Future<void> _guarded(String what, Future<void> Function() work) async {
    try {
      await work();
    } on Object catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'kairo coach',
          context: ErrorDescription(what),
          silent: true,
        ),
      );
    }
  }
}

/// The application's [KairoCoach].
final Provider<KairoCoach> coachProvider = Provider<KairoCoach>(
  (Ref ref) {
    final KairoCoach coach = KairoCoach(
      reminders: ref.watch(reminderRepositoryProvider),
      coach: ref.watch(coachRepositoryProvider),
      stats: ref.watch(reminderStatsRepositoryProvider),
      settings: ref.watch(settingsRepositoryProvider),
      scheduler: ref.watch(schedulerProvider),
      eventBus: ref.watch(eventBusProvider),
    );
    ref.onDispose(coach.dispose);
    return coach;
  },
);
