import 'package:flutter/foundation.dart';
import 'package:kairo_event_bus/event_bus.dart';

/// The coach has something to say that is not about any one reminder.
@immutable
class CoachSpokeEvent extends KairoEvent {
  const CoachSpokeEvent(this.line);

  final String line;

  @override
  String toString() => 'CoachSpokeEvent($line)';
}
