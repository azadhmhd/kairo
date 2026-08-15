import 'package:flutter/foundation.dart';

import 'daily_window.dart';

/// The kind of care a reminder is about.
///
/// Decides the icon and how the reminder is counted in reports, never when it
/// fires — that is the interval, which the user sets per reminder.
enum ReminderKind {
  /// Drink a glass of water.
  water,

  /// Stand up and move.
  stand,

  /// Look away from the screen.
  eyes,

  /// Something the user described themselves.
  custom,
}

/// A reminder the user has asked Kairo to keep making.
///
/// This is the standing instruction, not one firing of it. Each time it comes
/// due a `ReminderOccurrence` records what happened.
@immutable
class ReminderDefinition {
  /// Creates a reminder that repeats every [interval].
  const ReminderDefinition({
    required this.id,
    required this.kind,
    required this.label,
    required this.interval,
    this.activeHours,
    this.enabled = true,
  });

  /// Identifies this reminder for as long as it exists.
  final String id;

  /// What the reminder is about.
  final ReminderKind kind;

  /// What the user is shown when it fires.
  final String label;

  /// How long Kairo waits between one firing and the next.
  final Duration interval;

  /// The hours this reminder is allowed to fire in.
  ///
  /// `null` means all day. Quiet hours in the user's settings apply on top of
  /// this and can silence a reminder that is otherwise active.
  final DailyWindow? activeHours;

  /// Whether the reminder is currently being made. A disabled reminder keeps
  /// its history and settings; it simply stops coming due.
  final bool enabled;

  /// Returns a copy of this reminder with the given fields replaced.
  ///
  /// [activeHours] cannot be cleared this way; build a new definition to make
  /// a reminder all-day again.
  ReminderDefinition copyWith({
    ReminderKind? kind,
    String? label,
    Duration? interval,
    DailyWindow? activeHours,
    bool? enabled,
  }) {
    return ReminderDefinition(
      id: id,
      kind: kind ?? this.kind,
      label: label ?? this.label,
      interval: interval ?? this.interval,
      activeHours: activeHours ?? this.activeHours,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReminderDefinition &&
      other.id == id &&
      other.kind == kind &&
      other.label == label &&
      other.interval == interval &&
      other.activeHours == activeHours &&
      other.enabled == enabled;

  @override
  int get hashCode =>
      Object.hash(id, kind, label, interval, activeHours, enabled);

  @override
  String toString() =>
      'ReminderDefinition($id, ${kind.name}, every ${interval.inMinutes}m'
      '${enabled ? '' : ', disabled'})';
}
