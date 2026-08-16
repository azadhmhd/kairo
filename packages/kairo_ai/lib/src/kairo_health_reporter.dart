import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo_event_bus/event_bus.dart';
import 'package:kairo_scheduler/scheduler.dart';
import 'package:kairo_shared_models/shared_models.dart';
import 'package:kairo_storage/storage.dart';

import 'coach_prompt.dart';
import 'kairo_ai_client.dart';

/// Writes one summary of the user's habits a day. The coach rewords single
/// reminders; this reads the whole report back in words.
class KairoHealthReporter {
  KairoHealthReporter({
    required ReminderStatsRepository stats,
    required HealthReportRepository reports,
    required SettingsRepository settings,
    required KairoScheduler scheduler,
    required KairoEventBus eventBus,
    KairoAiClient client = const KairoAiClient(),
  })  : _stats = stats,
        _reports = reports,
        _settings = settings,
        _scheduler = scheduler,
        _eventBus = eventBus,
        _client = client;

  static const String scheduleId = 'kairo-health-report';

  static const int _maxTokens = 400;

  static const int _maxCharacters = 900;

  static const int _weekDays = 7;

  final ReminderStatsRepository _stats;
  final HealthReportRepository _reports;
  final SettingsRepository _settings;
  final KairoScheduler _scheduler;
  final KairoEventBus _eventBus;
  final KairoAiClient _client;

  UserSettings _current = UserSettings.defaults;
  bool _writing = false;

  StreamSubscription<UserSettings>? _settingsSubscription;
  StreamSubscription<ScheduleDueEvent>? _scheduleSubscription;

  /// Starts watching, and catches up if today's summary is already overdue.
  Future<void> start() async {
    _current = await _settings.read();
    _sync();

    _settingsSubscription = _settings.watch().listen((UserSettings settings) {
      final bool was = _current.ai.isUsable;
      _current = settings;
      _sync();
      if (was && !settings.ai.isUsable) {
        unawaited(_guarded('clearing summaries', _reports.clearAll));
      }
    });

    _scheduleSubscription =
        _eventBus.on<ScheduleDueEvent>().listen((ScheduleDueEvent event) {
      if (event.scheduleId == scheduleId) {
        unawaited(_guarded('writing the summary', _write));
      }
    });

    // A schedule only looks forward, so a machine that was closed through one
    // would otherwise wait a whole interval before catching up.
    unawaited(_guarded('writing the summary', _write));
  }

  Future<void> dispose() async {
    await _settingsSubscription?.cancel();
    await _scheduleSubscription?.cancel();
    _settingsSubscription = null;
    _scheduleSubscription = null;
    _scheduler.remove(scheduleId);
  }

  Future<void> _write() async {
    if (!_current.ai.isUsable || _writing) {
      return;
    }

    final DateTime now = DateTime.now();
    final HealthReport? last = await _reports.latest();
    if (last != null &&
        now.difference(last.generatedAt) < _current.ai.reportInterval) {
      return;
    }

    final DateTime today = DateTime(now.year, now.month, now.day);

    _writing = true;
    try {
      final DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
      final List<DailyTally> tallies = await _stats.dailyTallies(
        from: DateTime(now.year, now.month, now.day - 30),
        to: tomorrow,
      );

      DailyTally todays = DailyTally(day: today, due: 0, completed: 0);
      for (final DailyTally tally in tallies) {
        if (tally.day.year == today.year &&
            tally.day.month == today.month &&
            tally.day.day == today.day) {
          todays = tally;
        }
      }

      final List<KindTally> allTime = await _stats.talliesByKind(
        from: DateTime.fromMillisecondsSinceEpoch(0),
        to: tomorrow,
      );

      // Nothing has ever come due, so there is nothing to summarise. A quiet
      // day on its own is still worth writing about.
      if (allTime.every((KindTally t) => t.due == 0)) {
        return;
      }

      final List<KindTally> week = await _stats.talliesByKind(
        from: DateTime(now.year, now.month, now.day - (_weekDays - 1)),
        to: tomorrow,
      );

      final String body = await _client.complete(
        settings: _current.ai,
        system: reportSystemPrompt,
        prompt: reportPrompt(
          today: todays,
          week: week,
          allTime: allTime,
          streak: currentStreak(tallies, today: now),
        ),
        maxTokens: _maxTokens,
        maxCharacters: _maxCharacters,
      );

      await _reports.write(
        HealthReport(generatedAt: DateTime.now(), body: body),
      );
    } finally {
      _writing = false;
    }
  }

  void _sync() {
    if (!_current.ai.isUsable) {
      _scheduler.remove(scheduleId);
      return;
    }

    final KairoSchedule schedule =
        KairoSchedule.every(scheduleId, _current.ai.reportInterval);
    if (_scheduler.scheduleFor(scheduleId) != schedule) {
      _scheduler.add(schedule);
    }
  }

  Future<void> _guarded(String what, Future<void> Function() work) async {
    try {
      await work();
    } on Object catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'kairo health report',
          context: ErrorDescription(what),
          silent: true,
        ),
      );
    }
  }
}

/// The application's [KairoHealthReporter].
final Provider<KairoHealthReporter> healthReporterProvider =
    Provider<KairoHealthReporter>(
  (Ref ref) {
    final KairoHealthReporter reporter = KairoHealthReporter(
      stats: ref.watch(reminderStatsRepositoryProvider),
      reports: ref.watch(healthReportRepositoryProvider),
      settings: ref.watch(settingsRepositoryProvider),
      scheduler: ref.watch(schedulerProvider),
      eventBus: ref.watch(eventBusProvider),
    );
    ref.onDispose(reporter.dispose);
    return reporter;
  },
);
