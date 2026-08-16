import 'package:flutter/foundation.dart';

/// What became of one firing of a reminder.
enum ReminderOutcome {
  /// It has been shown, and the user has not answered yet.
  pending,

  /// The user said they did it.
  completed,

  /// The user asked to be reminded again shortly.
  snoozed,

  /// The user waved it away without doing it.
  dismissed,

  /// The user never answered, and the next one came due.
  missed,
}

/// One firing of a reminder, and what the user did about it.
///
/// Occurrences are the entire history Kairo has — every streak and completion
/// rate is counted from them. One is written the moment a reminder comes due
/// rather than when it is answered, so an ignored reminder is still recorded.
@immutable
class ReminderOccurrence {
  /// Creates a record of the reminder [definitionId] coming due at [dueAt].
  const ReminderOccurrence({
    required this.id,
    required this.definitionId,
    required this.dueAt,
    this.outcome = ReminderOutcome.pending,
    this.respondedAt,
  }) : assert(
          (respondedAt != null) ==
              (outcome == ReminderOutcome.completed ||
                  outcome == ReminderOutcome.snoozed ||
                  outcome == ReminderOutcome.dismissed),
          'an occurrence has a response time exactly when the user gave one: '
          'pending has not been answered yet, and missed never was',
        );

  /// Identifies this firing.
  final String id;

  /// The [ReminderDefinition] this came from.
  final String definitionId;

  /// When Kairo decided it was time.
  final DateTime dueAt;

  /// What became of it.
  final ReminderOutcome outcome;

  /// When the user answered, or `null` for the two outcomes they did not
  /// choose: still pending, and overtaken before it got an answer.
  final DateTime? respondedAt;

  /// Whether this is finished with, one way or another — answered or missed.
  /// Either way, a later answer would be answering a question no longer asked.
  bool get isAnswered => outcome != ReminderOutcome.pending;

  /// How long the user took to answer, or `null` if they have not.
  Duration? get responseTime => respondedAt?.difference(dueAt);

  /// Returns a copy of this occurrence answered with [outcome] at
  /// [respondedAt].
  ReminderOccurrence answered(ReminderOutcome outcome, DateTime respondedAt) {
    return ReminderOccurrence(
      id: id,
      definitionId: definitionId,
      dueAt: dueAt,
      outcome: outcome,
      respondedAt: respondedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReminderOccurrence &&
      other.id == id &&
      other.definitionId == definitionId &&
      other.dueAt == dueAt &&
      other.outcome == outcome &&
      other.respondedAt == respondedAt;

  @override
  int get hashCode =>
      Object.hash(id, definitionId, dueAt, outcome, respondedAt);

  @override
  String toString() =>
      'ReminderOccurrence($id, $definitionId, due $dueAt, ${outcome.name})';
}
