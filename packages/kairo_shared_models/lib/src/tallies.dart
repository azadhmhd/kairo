import 'package:flutter/foundation.dart';

import 'reminder_definition.dart';

/// What happened on one day.
///
/// Counted from the occurrences that came due that day. A day with no row is a
/// day Kairo was not running, not a day the user ignored it, so nothing here
/// treats a missing day as a failure.
@immutable
class DailyTally {
  /// Records that [completed] of [due] reminders were finished on [day].
  const DailyTally({
    required this.day,
    required this.due,
    required this.completed,
    this.missed = 0,
    this.dismissed = 0,
    this.snoozed = 0,
  });

  /// Local midnight of the day being counted.
  final DateTime day;

  /// How many reminders came due.
  final int due;

  /// How many of them the user marked done.
  final int completed;

  /// How many went unanswered until Kairo gave up asking.
  final int missed;

  final int dismissed;

  final int snoozed;

  /// The share of the day's reminders that were completed, from 0 to 1. Zero on
  /// a day nothing came due, which charts better than a gap.
  double get completionRate => due == 0 ? 0 : completed / due;

  /// Whether this day counts towards a streak. One completed reminder is
  /// enough; demanding a perfect day would break on the first long meeting.
  bool get isKept => completed > 0;

  @override
  bool operator ==(Object other) =>
      other is DailyTally &&
      other.day == day &&
      other.due == due &&
      other.completed == completed &&
      other.missed == missed &&
      other.dismissed == dismissed &&
      other.snoozed == snoozed;

  @override
  int get hashCode =>
      Object.hash(day, due, completed, missed, dismissed, snoozed);

  @override
  String toString() => 'DailyTally($day, $completed of $due)';
}

/// What happened to one kind of reminder over a stretch of days.
@immutable
class KindTally {
  /// Records that [completed] of [due] [kind] reminders were finished.
  const KindTally({
    required this.kind,
    required this.due,
    required this.completed,
    this.missed = 0,
    this.dismissed = 0,
    this.snoozed = 0,
  });

  /// Which kind of reminder this counts.
  final ReminderKind kind;

  /// How many came due.
  final int due;

  /// How many the user marked done.
  final int completed;

  /// How many went unanswered until Kairo gave up asking.
  final int missed;

  final int dismissed;

  final int snoozed;

  /// The share completed, from 0 to 1.
  double get completionRate => due == 0 ? 0 : completed / due;

  @override
  bool operator ==(Object other) =>
      other is KindTally &&
      other.kind == kind &&
      other.due == due &&
      other.completed == completed &&
      other.missed == missed &&
      other.dismissed == dismissed &&
      other.snoozed == snoozed;

  @override
  int get hashCode =>
      Object.hash(kind, due, completed, missed, dismissed, snoozed);

  @override
  String toString() => 'KindTally(${kind.name}, $completed of $due)';
}
