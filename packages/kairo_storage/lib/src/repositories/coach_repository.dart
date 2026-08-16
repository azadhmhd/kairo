import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo_shared_models/shared_models.dart';

import '../database/kairo_database.dart';

/// Reads and writes the lines the coach has written. The whole boundary
/// between Kairo's AI and the rest of it.
class CoachRepository {
  const CoachRepository(this._database);

  final KairoDatabase _database;

  Future<CoachLine?> line(String definitionId) async {
    final CoachLineRow? row = await (_database.select(_database.coachLines)
          ..where(($CoachLinesTable t) => t.definitionId.equals(definitionId)))
        .getSingleOrNull();
    return row == null ? null : _toLine(row);
  }

  Stream<Map<String, String>> watchMessages() {
    return _database.select(_database.coachLines).watch().map(
          (List<CoachLineRow> rows) => <String, String>{
            for (final CoachLineRow row in rows) row.definitionId: row.message,
          },
        );
  }

  Future<void> write(CoachLine line) {
    return _database.into(_database.coachLines).insertOnConflictUpdate(
          CoachLinesCompanion.insert(
            definitionId: line.definitionId,
            message: line.message,
            stance: line.stance,
            generatedAt: line.generatedAt,
          ),
        );
  }

  Future<void> clear(String definitionId) {
    return (_database.delete(_database.coachLines)
          ..where(($CoachLinesTable t) => t.definitionId.equals(definitionId)))
        .go();
  }

  Stream<Map<ReminderOutcome, List<String>>> watchReactions() {
    return _database.select(_database.coachReactions).watch().map(_group);
  }

  Future<DateTime?> reactionsWrittenAt(ReminderOutcome outcome) async {
    final CoachReactionRow? row = await (_database
            .select(_database.coachReactions)
          ..where(($CoachReactionsTable t) => t.outcome.equalsValue(outcome))
          ..limit(1))
        .getSingleOrNull();
    return row?.generatedAt;
  }

  Future<void> replaceReactions(
    ReminderOutcome outcome,
    List<String> messages,
    DateTime at,
  ) {
    return _database.transaction(() async {
      await (_database.delete(_database.coachReactions)
            ..where(($CoachReactionsTable t) => t.outcome.equalsValue(outcome)))
          .go();
      for (final String message in messages) {
        await _database.into(_database.coachReactions).insert(
              CoachReactionsCompanion.insert(
                outcome: outcome,
                message: message,
                generatedAt: at,
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
    });
  }

  Future<void> clearAll() async {
    await _database.delete(_database.coachLines).go();
    await _database.delete(_database.coachReactions).go();
  }

  Map<ReminderOutcome, List<String>> _group(List<CoachReactionRow> rows) {
    final Map<ReminderOutcome, List<String>> grouped =
        <ReminderOutcome, List<String>>{};
    for (final CoachReactionRow row in rows) {
      grouped.putIfAbsent(row.outcome, () => <String>[]).add(row.message);
    }
    return grouped;
  }

  CoachLine _toLine(CoachLineRow row) {
    return CoachLine(
      definitionId: row.definitionId,
      message: row.message,
      stance: row.stance,
      generatedAt: row.generatedAt,
    );
  }
}

final Provider<CoachRepository> coachRepositoryProvider =
    Provider<CoachRepository>(
  (Ref ref) => CoachRepository(ref.watch(databaseProvider)),
);
