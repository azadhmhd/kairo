import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo_shared_models/shared_models.dart';

import '../database/kairo_database.dart';

/// Reads and writes the written summaries of how the user is doing.
class HealthReportRepository {
  const HealthReportRepository(this._database);

  final KairoDatabase _database;

  Future<HealthReport?> latest() async {
    final HealthReportRow? row = await (_newestFirst()..limit(1))
        .getSingleOrNull();
    return row == null ? null : _toReport(row);
  }

  Stream<HealthReport?> watchLatest() {
    return (_newestFirst()..limit(1))
        .watchSingleOrNull()
        .map((HealthReportRow? row) => row == null ? null : _toReport(row));
  }

  Future<List<HealthReport>> recent({required int limit}) async {
    final List<HealthReportRow> rows =
        await (_newestFirst()..limit(limit)).get();
    return rows.map(_toReport).toList();
  }

  Future<void> write(HealthReport report) {
    return _database.into(_database.healthReports).insertOnConflictUpdate(
          HealthReportsCompanion.insert(
            generatedAt: report.generatedAt,
            body: report.body,
          ),
        );
  }

  Future<void> clearAll() => _database.delete(_database.healthReports).go();

  SimpleSelectStatement<$HealthReportsTable, HealthReportRow> _newestFirst() {
    return _database.select(_database.healthReports)
      ..orderBy(<OrderClauseGenerator<$HealthReportsTable>>[
        ($HealthReportsTable t) => OrderingTerm.desc(t.generatedAt),
      ]);
  }

  HealthReport _toReport(HealthReportRow row) {
    return HealthReport(generatedAt: row.generatedAt, body: row.body);
  }
}

final Provider<HealthReportRepository> healthReportRepositoryProvider =
    Provider<HealthReportRepository>(
  (Ref ref) => HealthReportRepository(ref.watch(databaseProvider)),
);
