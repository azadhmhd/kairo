import 'package:flutter/foundation.dart';

/// A standing instruction to announce that something is due.
///
/// A name and a rhythm, nothing more: the workflow engine decides whether to
/// act on it, and the reminder engine decides what it means.
///
/// A schedule either repeats on an [interval] or fires once a day at a fixed
/// [minuteOfDay]. Exactly one of the two is set.
@immutable
class KairoSchedule {
  /// Announces [id] every [interval], starting one interval from when it is
  /// added.
  const KairoSchedule.every(this.id, Duration this.interval)
      : minuteOfDay = null,
        assert(interval > Duration.zero, 'an interval must move time forward');

  /// Announces [id] once a day, at [minuteOfDay] minutes past midnight.
  const KairoSchedule.dailyAt(this.id, int this.minuteOfDay)
      : interval = null,
        assert(
          minuteOfDay >= 0 && minuteOfDay < 24 * 60,
          'minuteOfDay is not a minute of the day',
        );

  /// Identifies this schedule. Adding a second schedule with the same id
  /// replaces the first.
  final String id;

  /// How long between announcements, or null for a daily schedule.
  final Duration? interval;

  /// Minutes past midnight, or null for a repeating schedule.
  final int? minuteOfDay;

  /// Whether this schedule repeats on an interval rather than daily.
  bool get repeats => interval != null;

  /// When this schedule is next due, given that it is [from] now.
  ///
  /// For a repeating schedule that is simply one interval away. For a daily
  /// schedule it is today's time if that has not passed, and tomorrow's if it
  /// has.
  DateTime nextAfter(DateTime from) {
    final Duration? every = interval;
    if (every != null) {
      return from.add(every);
    }

    final int minute = minuteOfDay!;
    final DateTime todayAt = DateTime(
      from.year,
      from.month,
      from.day,
    ).add(Duration(minutes: minute));
    return todayAt.isAfter(from)
        ? todayAt
        : todayAt.add(const Duration(days: 1));
  }

  @override
  bool operator ==(Object other) =>
      other is KairoSchedule &&
      other.id == id &&
      other.interval == interval &&
      other.minuteOfDay == minuteOfDay;

  @override
  int get hashCode => Object.hash(id, interval, minuteOfDay);

  @override
  String toString() => repeats
      ? 'KairoSchedule($id, every ${interval!.inMinutes}m)'
      : 'KairoSchedule($id, daily at minute $minuteOfDay)';
}
