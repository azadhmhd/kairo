import 'package:flutter/foundation.dart';

enum CoachStance { slipping, thriving }

/// What Kairo says for one reminder instead of the user's own wording.
@immutable
class CoachLine {
  const CoachLine({
    required this.definitionId,
    required this.message,
    required this.stance,
    required this.generatedAt,
  });

  final String definitionId;
  final String message;
  final CoachStance stance;
  final DateTime generatedAt;

  @override
  bool operator ==(Object other) =>
      other is CoachLine &&
      other.definitionId == definitionId &&
      other.message == message &&
      other.stance == stance &&
      other.generatedAt == generatedAt;

  @override
  int get hashCode => Object.hash(definitionId, message, stance, generatedAt);

  @override
  String toString() => 'CoachLine($definitionId, ${stance.name})';
}
