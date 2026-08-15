import 'package:flutter/foundation.dart';
import 'package:kairo_event_bus/event_bus.dart';
import 'package:kairo_shared_models/shared_models.dart';

/// A reminder is due, and Kairo has decided it should be shown.
///
/// The occurrence is already recorded by the time this is published, so a
/// listener that reads the history sees the reminder it was just told about.
@immutable
class ReminderDueEvent extends KairoEvent {
  /// Announces [occurrence], which came from [definition].
  const ReminderDueEvent({required this.definition, required this.occurrence});

  /// The standing reminder this came from. Carries the wording and the kind,
  /// so a listener does not have to go back to storage to know what to show.
  final ReminderDefinition definition;

  /// This particular firing, already recorded as pending.
  final ReminderOccurrence occurrence;

  @override
  String toString() => 'ReminderDueEvent(${definition.id}, due ${occurrence.dueAt})';
}

/// The user said what they wanted to do about a reminder.
///
/// Published after the answer is written down, for the same reason as
/// [ReminderDueEvent].
@immutable
class ReminderAnsweredEvent extends KairoEvent {
  /// Announces that [occurrence] has been answered.
  const ReminderAnsweredEvent(this.occurrence);

  /// The occurrence, carrying its outcome and the time it was answered.
  final ReminderOccurrence occurrence;

  /// What the user chose.
  ReminderOutcome get outcome => occurrence.outcome;

  @override
  String toString() =>
      'ReminderAnsweredEvent(${occurrence.definitionId}, ${outcome.name})';
}
