import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo_event_bus/event_bus.dart';
import 'package:kairo_reminder_engine/reminder_engine.dart';
import 'package:kairo_shared_models/shared_models.dart';
import 'package:kairo_storage/storage.dart';

/// The day the user means by "today", as a local midnight.
///
/// Invalidates itself at the rollover, so an app left running overnight stops
/// showing yesterday. A machine asleep at midnight fires the timer late rather
/// than never, which corrects the same way.
final Provider<DateTime> todayProvider = Provider<DateTime>((Ref ref) {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);

  final Timer rollover = Timer(tomorrow.difference(now), ref.invalidateSelf);
  ref.onDispose(rollover.cancel);

  return today;
});

/// A clock for anything showing a time relative to now. Half a minute is close
/// enough for countdowns measured in tens of minutes.
final StreamProvider<DateTime> clockProvider = StreamProvider<DateTime>(
  (Ref ref) async* {
    yield DateTime.now();
    yield* Stream<void>.periodic(const Duration(seconds: 30))
        .map((void _) => DateTime.now());
  },
);

/// Every reminder the user has, refreshed as they are changed.
final StreamProvider<List<ReminderDefinition>> reminderDefinitionsProvider =
    StreamProvider<List<ReminderDefinition>>(
  (Ref ref) => ref.watch(reminderRepositoryProvider).watchDefinitions(),
);

/// Everything that came due today, refreshed as it happens.
final StreamProvider<List<ReminderOccurrence>> todaysOccurrencesProvider =
    StreamProvider<List<ReminderOccurrence>>(
  (Ref ref) => ref
      .watch(reminderRepositoryProvider)
      .watchOccurrencesForDay(ref.watch(todayProvider)),
);

/// The reminder waiting for an answer, or null when there is none.
///
/// One stream rather than two pieces of state: a due event puts a reminder on
/// screen and an answered event takes it away, so the banner cannot get stuck
/// showing something already dealt with.
final StreamProvider<ReminderDueEvent?> currentReminderProvider =
    StreamProvider<ReminderDueEvent?>((Ref ref) {
  return ref
      .watch(eventBusProvider)
      .events
      .where(
        (KairoEvent event) =>
            event is ReminderDueEvent || event is ReminderAnsweredEvent,
      )
      .map(
        (KairoEvent event) => event is ReminderDueEvent ? event : null,
      );
});

/// How many of today's reminders the user has completed.
final Provider<int> completedTodayProvider = Provider<int>((Ref ref) {
  final List<ReminderOccurrence> occurrences =
      ref.watch(todaysOccurrencesProvider).valueOrNull ??
          const <ReminderOccurrence>[];
  return occurrences
      .where(
        (ReminderOccurrence o) => o.outcome == ReminderOutcome.completed,
      )
      .length;
});
