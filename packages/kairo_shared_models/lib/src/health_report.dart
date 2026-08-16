import 'package:flutter/foundation.dart';

/// A written summary of how the user's habits have been going, covering
/// everything Kairo knew when it was written.
@immutable
class HealthReport {
  const HealthReport({required this.generatedAt, required this.body});

  final DateTime generatedAt;
  final String body;

  @override
  bool operator ==(Object other) =>
      other is HealthReport &&
      other.generatedAt == generatedAt &&
      other.body == body;

  @override
  int get hashCode => Object.hash(generatedAt, body);

  @override
  String toString() => 'HealthReport($generatedAt, ${body.length} characters)';
}
