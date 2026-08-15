import 'package:flutter/foundation.dart';
import 'package:kairo_event_bus/event_bus.dart';

/// A schedule reached its time.
///
/// Says only that the clock arrived, never that anything should be shown.
@immutable
class ScheduleDueEvent extends KairoEvent {
  /// Announces that the schedule [scheduleId] was due at [dueAt].
  const ScheduleDueEvent(this.scheduleId, this.dueAt);

  /// Which schedule came due.
  final String scheduleId;

  /// The moment it was due — the time owed, not the instant this was published,
  /// which is up to one tick later. History should record this, not the clock.
  final DateTime dueAt;

  @override
  String toString() => 'ScheduleDueEvent($scheduleId, due $dueAt)';
}
