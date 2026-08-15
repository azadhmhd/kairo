import 'package:flutter/foundation.dart';

/// A stretch of the day, repeated every day.
///
/// Both ends are minutes past midnight, so a window stores as two integers and
/// never carries a date it does not mean.
///
/// A window may wrap past midnight: 22:00–07:00 is
/// `DailyWindow(from: 1320, to: 420)`, which [contains] reads as the two
/// stretches either side of midnight rather than as an empty range.
@immutable
class DailyWindow {
  /// Creates the window running from [from] to [to], in minutes past midnight.
  ///
  /// Both ends must be in `0..1439`. [from] equal to [to] is a window of zero
  /// length, not a window covering the whole day.
  const DailyWindow({required this.from, required this.to})
      : assert(from >= 0 && from < minutesPerDay, 'from is not a minute of the day'),
        assert(to >= 0 && to < minutesPerDay, 'to is not a minute of the day');

  /// Creates a window from wall-clock hours and minutes.
  const DailyWindow.between({
    required int fromHour,
    required int fromMinute,
    required int toHour,
    required int toMinute,
  }) : this(from: fromHour * 60 + fromMinute, to: toHour * 60 + toMinute);

  /// How many minutes there are in a day.
  static const int minutesPerDay = 24 * 60;

  /// The first minute of the window, counted from midnight.
  final int from;

  /// The minute the window ends, counted from midnight. Exclusive.
  final int to;

  /// Whether this window wraps past midnight.
  bool get wrapsMidnight => to < from;

  /// Whether [time] falls inside the window.
  ///
  /// Only the clock reading matters; the date is ignored.
  bool contains(DateTime time) {
    final int minute = time.hour * 60 + time.minute;
    return wrapsMidnight
        ? minute >= from || minute < to
        : minute >= from && minute < to;
  }

  @override
  bool operator ==(Object other) =>
      other is DailyWindow && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);

  @override
  String toString() {
    String clock(int minute) =>
        '${(minute ~/ 60).toString().padLeft(2, '0')}:'
        '${(minute % 60).toString().padLeft(2, '0')}';
    return '${clock(from)}–${clock(to)}';
  }
}
