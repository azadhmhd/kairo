import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo_shared_models/shared_models.dart';

import '../database/kairo_database.dart';

/// Counts Kairo's history into the numbers a report is made of.
///
/// Everything here is a `GROUP BY` over the occurrences table. There is no
/// separate analytics store to keep in step.
class ReminderStatsRepository {
  /// Creates a repository reading from [_database].
  const ReminderStatsRepository(this._database);

  final KairoDatabase _database;

  /// One tally per day between [from] and [to], for days that have any.
  ///
  /// Days on which nothing came due are absent rather than zero; a caller
  /// drawing a chart fills the gaps itself.
  Future<List<DailyTally>> dailyTallies({
    required DateTime from,
    required DateTime to,
  }) async {
    final List<QueryRow> rows = await _dailyQuery(from: from, to: to).get();
    return rows.map(_toDailyTally).toList();
  }

  /// The same tallies, re-counted whenever the history changes.
  Stream<List<DailyTally>> watchDailyTallies({
    required DateTime from,
    required DateTime to,
  }) {
    return _dailyQuery(from: from, to: to).watch().map(
          (List<QueryRow> rows) => rows.map(_toDailyTally).toList(),
        );
  }

  /// One tally per kind of reminder between [from] and [to].
  Future<List<KindTally>> talliesByKind({
    required DateTime from,
    required DateTime to,
  }) async {
    final List<QueryRow> rows = await _database.customSelect(
      '''
      SELECT d.kind AS kind,
             COUNT(*) AS due,
             SUM(CASE WHEN o.outcome = ? THEN 1 ELSE 0 END) AS completed
      FROM reminder_occurrences o
      JOIN reminder_definitions d ON d.id = o.definition_id
      WHERE o.due_at >= ? AND o.due_at < ?
      GROUP BY d.kind
      ''',
      variables: <Variable<Object>>[
        Variable<String>(ReminderOutcome.completed.name),
        Variable<DateTime>(from),
        Variable<DateTime>(to),
      ],
      readsFrom: <ResultSetImplementation<Object, Object>>{
        _database.reminderOccurrences,
        _database.reminderDefinitions,
      },
    ).get();

    return rows.map((QueryRow row) {
      final String name = row.read<String>('kind');
      return KindTally(
        kind: ReminderKind.values.firstWhere(
          (ReminderKind kind) => kind.name == name,
          orElse: () => ReminderKind.custom,
        ),
        due: row.read<int>('due'),
        completed: row.read<int>('completed'),
      );
    }).toList();
  }

  Selectable<QueryRow> _dailyQuery({
    required DateTime from,
    required DateTime to,
  }) {
    // Drift stores a DateTime as whole seconds since the epoch, so SQLite needs
    // telling how to read the column before it can group by calendar day. The
    // 'localtime' modifier is what makes a day mean the user's day rather than
    // UTC's — without it, everything after early evening lands on tomorrow.
    return _database.customSelect(
      '''
      SELECT date(due_at, 'unixepoch', 'localtime') AS day,
             COUNT(*) AS due,
             SUM(CASE WHEN outcome = ? THEN 1 ELSE 0 END) AS completed
      FROM reminder_occurrences
      WHERE due_at >= ? AND due_at < ?
      GROUP BY day
      ORDER BY day
      ''',
      variables: <Variable<Object>>[
        Variable<String>(ReminderOutcome.completed.name),
        Variable<DateTime>(from),
        Variable<DateTime>(to),
      ],
      readsFrom: <ResultSetImplementation<Object, Object>>{
        _database.reminderOccurrences,
      },
    );
  }

  DailyTally _toDailyTally(QueryRow row) {
    return DailyTally(
      day: DateTime.parse(row.read<String>('day')),
      due: row.read<int>('due'),
      completed: row.read<int>('completed'),
    );
  }
}

/// How many days in a row the user has completed at least one reminder.
///
/// Counted backwards from [today]. A day with nothing completed ends the
/// streak, and so does a day Kairo was not running — there is no evidence
/// either way, and assuming one would make the number a lie.
///
/// Today is the exception: a streak is not broken until the day is over, so a
/// morning with nothing done yet keeps yesterday's count.
int currentStreak(List<DailyTally> tallies, {required DateTime today}) {
  final Map<DateTime, DailyTally> byDay = <DateTime, DailyTally>{
    for (final DailyTally tally in tallies)
      DateTime(tally.day.year, tally.day.month, tally.day.day): tally,
  };

  DateTime cursor = DateTime(today.year, today.month, today.day);
  if (byDay[cursor]?.isKept != true) {
    cursor = _dayBefore(cursor);
  }

  int streak = 0;
  while (byDay[cursor]?.isKept ?? false) {
    streak++;
    cursor = _dayBefore(cursor);
  }
  return streak;
}

/// The calendar day before [day].
///
/// Built from the date parts, not by subtracting 24 hours: on the two days a
/// year the clocks change a day is 23 or 25 hours, and a fixed subtraction
/// would land on the wrong date and silently break the streak.
DateTime _dayBefore(DateTime day) =>
    DateTime(day.year, day.month, day.day - 1);

/// The application's [ReminderStatsRepository].
final Provider<ReminderStatsRepository> reminderStatsRepositoryProvider =
    Provider<ReminderStatsRepository>(
  (Ref ref) => ReminderStatsRepository(ref.watch(databaseProvider)),
);
