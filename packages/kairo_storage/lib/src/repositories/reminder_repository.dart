import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo_shared_models/shared_models.dart';

import '../database/kairo_database.dart';

/// Reads and writes reminders and their history.
///
/// Callers hand over and receive models from `kairo_shared_models`; rows,
/// columns and queries stop here.
class ReminderRepository {
  /// Creates a repository backed by [_database].
  const ReminderRepository(this._database);

  final KairoDatabase _database;

  /// Every reminder the user has, enabled or not, oldest label first.
  Future<List<ReminderDefinition>> definitions() async {
    final List<ReminderDefinitionRow> rows = await (_database
            .select(_database.reminderDefinitions)
          ..orderBy(<OrderClauseGenerator<$ReminderDefinitionsTable>>[
            ($ReminderDefinitionsTable t) => OrderingTerm.asc(t.label),
          ]))
        .get();
    return rows.map(_toDefinition).toList();
  }

  /// Emits the reminders, and emits again whenever any of them changes. The
  /// dashboard follows this rather than re-reading.
  Stream<List<ReminderDefinition>> watchDefinitions() {
    return (_database.select(_database.reminderDefinitions)
          ..orderBy(<OrderClauseGenerator<$ReminderDefinitionsTable>>[
            ($ReminderDefinitionsTable t) => OrderingTerm.asc(t.label),
          ]))
        .watch()
        .map((List<ReminderDefinitionRow> rows) =>
            rows.map(_toDefinition).toList());
  }

  /// The reminder [id], or null if there is none.
  Future<ReminderDefinition?> definition(String id) async {
    final ReminderDefinitionRow? row =
        await (_database.select(_database.reminderDefinitions)
              ..where(($ReminderDefinitionsTable t) => t.id.equals(id)))
            .getSingleOrNull();
    return row == null ? null : _toDefinition(row);
  }

  /// Writes [definition], replacing any reminder that already has its id.
  Future<void> upsertDefinition(ReminderDefinition definition) {
    return _database
        .into(_database.reminderDefinitions)
        .insertOnConflictUpdate(_fromDefinition(definition));
  }

  /// Removes the reminder [id], and with it everything it ever recorded.
  Future<void> deleteDefinition(String id) {
    return (_database.delete(_database.reminderDefinitions)
          ..where(($ReminderDefinitionsTable t) => t.id.equals(id)))
        .go();
  }

  /// Adds [definition] only if no reminder with its id exists yet. How the
  /// defaults are seeded without overwriting the user's edits on relaunch.
  Future<void> insertIfAbsent(ReminderDefinition definition) {
    return _database
        .into(_database.reminderDefinitions)
        .insert(_fromDefinition(definition), mode: InsertMode.insertOrIgnore);
  }

  /// Records that a reminder came due, before the user has answered.
  Future<void> recordDue(ReminderOccurrence occurrence) {
    return _database
        .into(_database.reminderOccurrences)
        .insert(_fromOccurrence(occurrence));
  }

  /// Records what the user did about the occurrence [id].
  ///
  /// Does nothing if the occurrence is not there, which is the right answer
  /// when a stale reminder window is answered after its row has been cleared.
  Future<void> recordOutcome(
    String id,
    ReminderOutcome outcome,
    DateTime respondedAt,
  ) {
    return (_database.update(_database.reminderOccurrences)
          ..where(($ReminderOccurrencesTable t) => t.id.equals(id)))
        .write(
      ReminderOccurrencesCompanion(
        outcome: Value<ReminderOutcome>(outcome),
        respondedAt: Value<DateTime?>(respondedAt),
      ),
    );
  }

  /// How the last [limit] settled firings of [definitionId] ended, newest
  /// first. Pending ones are excluded: they have not been ignored yet.
  Future<List<ReminderOutcome>> recentOutcomes(
    String definitionId, {
    required int limit,
  }) async {
    final List<ReminderOccurrenceRow> rows = await (_database
            .select(_database.reminderOccurrences)
          ..where(($ReminderOccurrencesTable t) =>
              t.definitionId.equals(definitionId) &
              t.outcome.equalsValue(ReminderOutcome.pending).not())
          ..orderBy(<OrderClauseGenerator<$ReminderOccurrencesTable>>[
            ($ReminderOccurrencesTable t) => OrderingTerm.desc(t.dueAt),
          ])
          ..limit(limit))
        .get();
    return rows.map((ReminderOccurrenceRow row) => row.outcome).toList();
  }

  /// Every occurrence that came due on the calendar day containing [day],
  /// bounded by local midnights rather than UTC.
  Future<List<ReminderOccurrence>> occurrencesForDay(DateTime day) async {
    final DateTime start = DateTime(day.year, day.month, day.day);
    final DateTime end = start.add(const Duration(days: 1));

    final List<ReminderOccurrenceRow> rows = await (_database
            .select(_database.reminderOccurrences)
          ..where(($ReminderOccurrencesTable t) =>
              t.dueAt.isBiggerOrEqualValue(start) & t.dueAt.isSmallerThanValue(end))
          ..orderBy(<OrderClauseGenerator<$ReminderOccurrencesTable>>[
            ($ReminderOccurrencesTable t) => OrderingTerm.asc(t.dueAt),
          ]))
        .get();
    return rows.map(_toOccurrence).toList();
  }

  /// Emits the occurrences for [day], and emits again as they change.
  Stream<List<ReminderOccurrence>> watchOccurrencesForDay(DateTime day) {
    final DateTime start = DateTime(day.year, day.month, day.day);
    final DateTime end = start.add(const Duration(days: 1));

    return (_database.select(_database.reminderOccurrences)
          ..where(($ReminderOccurrencesTable t) =>
              t.dueAt.isBiggerOrEqualValue(start) & t.dueAt.isSmallerThanValue(end))
          ..orderBy(<OrderClauseGenerator<$ReminderOccurrencesTable>>[
            ($ReminderOccurrencesTable t) => OrderingTerm.asc(t.dueAt),
          ]))
        .watch()
        .map((List<ReminderOccurrenceRow> rows) =>
            rows.map(_toOccurrence).toList());
  }

  /// Marks every occurrence of [definitionId] still pending before [before] as
  /// missed. Called when the next reminder comes due and overtakes it.
  Future<void> expirePending(String definitionId, DateTime before) {
    return (_database.update(_database.reminderOccurrences)
          ..where(($ReminderOccurrencesTable t) =>
              t.definitionId.equals(definitionId) &
              t.dueAt.isSmallerThanValue(before) &
              t.outcome.equalsValue(ReminderOutcome.pending)))
        .write(
      ReminderOccurrencesCompanion(
        outcome: Value<ReminderOutcome>(ReminderOutcome.missed),
      ),
    );
  }

  ReminderDefinition _toDefinition(ReminderDefinitionRow row) {
    return ReminderDefinition(
      id: row.id,
      kind: row.kind,
      label: row.label,
      interval: Duration(seconds: row.intervalSeconds),
      activeHours: row.activeFromMinute == null || row.activeToMinute == null
          ? null
          : DailyWindow(from: row.activeFromMinute!, to: row.activeToMinute!),
      enabled: row.enabled,
    );
  }

  ReminderDefinitionsCompanion _fromDefinition(ReminderDefinition definition) {
    return ReminderDefinitionsCompanion.insert(
      id: definition.id,
      kind: definition.kind,
      label: definition.label,
      intervalSeconds: definition.interval.inSeconds,
      activeFromMinute: Value<int?>(definition.activeHours?.from),
      activeToMinute: Value<int?>(definition.activeHours?.to),
      enabled: Value<bool>(definition.enabled),
    );
  }

  ReminderOccurrence _toOccurrence(ReminderOccurrenceRow row) {
    return ReminderOccurrence(
      id: row.id,
      definitionId: row.definitionId,
      dueAt: row.dueAt,
      outcome: row.outcome,
      respondedAt: row.respondedAt,
    );
  }

  ReminderOccurrencesCompanion _fromOccurrence(ReminderOccurrence occurrence) {
    return ReminderOccurrencesCompanion.insert(
      id: occurrence.id,
      definitionId: occurrence.definitionId,
      dueAt: occurrence.dueAt,
      outcome: occurrence.outcome,
      respondedAt: Value<DateTime?>(occurrence.respondedAt),
    );
  }
}

/// The application's [ReminderRepository].
final Provider<ReminderRepository> reminderRepositoryProvider =
    Provider<ReminderRepository>(
  (Ref ref) => ReminderRepository(ref.watch(databaseProvider)),
);
