import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo_shared_models/shared_models.dart';
import 'package:kairo_storage/storage.dart';

import '../../reminders/application/reminder_providers.dart';

/// How many days back a report looks.
final StateProvider<int> reportRangeProvider = StateProvider<int>((Ref ref) => 7);

/// The window a report covers: [reportRangeProvider] days ending tonight.
///
/// Derived from [todayProvider], so a report left open overnight moves with the
/// date rather than describing a window that ended yesterday.
final Provider<({DateTime from, DateTime to})> reportWindowProvider =
    Provider<({DateTime from, DateTime to})>((Ref ref) {
  final DateTime today = ref.watch(todayProvider);
  final int days = ref.watch(reportRangeProvider);
  return (
    from: DateTime(today.year, today.month, today.day - (days - 1)),
    to: DateTime(today.year, today.month, today.day + 1),
  );
});

/// One tally per day in the report window, re-counted as history is made.
final StreamProvider<List<DailyTally>> dailyTalliesProvider =
    StreamProvider<List<DailyTally>>((Ref ref) {
  final ({DateTime from, DateTime to}) window = ref.watch(reportWindowProvider);
  return ref
      .watch(reminderStatsRepositoryProvider)
      .watchDailyTallies(from: window.from, to: window.to);
});

/// Every day in the report window, including the ones with nothing on them.
///
/// The database returns only days that have rows. A chart needs the gaps too,
/// or a week Kairo was closed for two days would draw as a five-day week.
final Provider<List<DailyTally>> dailyTalliesFilledProvider =
    Provider<List<DailyTally>>((Ref ref) {
  final List<DailyTally> counted =
      ref.watch(dailyTalliesProvider).valueOrNull ?? const <DailyTally>[];
  final Map<DateTime, DailyTally> byDay = <DateTime, DailyTally>{
    for (final DailyTally tally in counted)
      DateTime(tally.day.year, tally.day.month, tally.day.day): tally,
  };

  final DateTime today = ref.watch(todayProvider);
  final int days = ref.watch(reportRangeProvider);

  return <DailyTally>[
    for (int offset = days - 1; offset >= 0; offset--)
      () {
        final DateTime day =
            DateTime(today.year, today.month, today.day - offset);
        return byDay[day] ?? DailyTally(day: day, due: 0, completed: 0);
      }(),
  ];
});

/// How many days in a row the user has completed at least one reminder.
///
/// Counted over the report window, so a streak longer than the window is capped
/// at the window's length and widening the range widens the answer.
final Provider<int> streakProvider = Provider<int>((Ref ref) {
  return currentStreak(
    ref.watch(dailyTalliesProvider).valueOrNull ?? const <DailyTally>[],
    today: ref.watch(todayProvider),
  );
});

/// One tally per kind of reminder over the report window.
final FutureProvider<List<KindTally>> kindTalliesProvider =
    FutureProvider<List<KindTally>>((Ref ref) {
  final ({DateTime from, DateTime to}) window = ref.watch(reportWindowProvider);

  // Re-read whenever the day's history changes, so the breakdown and the chart
  // never disagree about the same window.
  ref.watch(dailyTalliesProvider);

  return ref
      .watch(reminderStatsRepositoryProvider)
      .talliesByKind(from: window.from, to: window.to);
});
