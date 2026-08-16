import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/kairo_database.dart';

/// Whole-database operations: taking the user's data out, and destroying it.
///
/// Keeping everything local only means something if the user can also export it
/// and delete it, which is what these two methods are for.
class KairoDataRepository {
  /// Creates a repository operating on [_database].
  const KairoDataRepository(this._database);

  final KairoDatabase _database;

  /// The columns an export leaves out. An export is a file the user moves and
  /// attaches to things; the API key must not travel with it.
  static const Set<String> _withheldColumns = <String>{
    'ai_enabled',
    'ai_base_url',
    'ai_model',
    'ai_api_key',
  };

  /// Writes everything Kairo knows about the user to a JSON file, and returns
  /// where it went. Coach lines and AI settings are excluded.
  Future<File> exportToFile() async {
    final Map<String, Object?> contents = <String, Object?>{
      'exportedAt': DateTime.now().toIso8601String(),
      'schemaVersion': _database.schemaVersion,
      'reminders': await _rowsOf(_database.reminderDefinitions),
      'occurrences': await _rowsOf(_database.reminderOccurrences),
      'settings': await _rowsOf(_database.userSettingsTable),
    };

    final Directory directory = await getApplicationSupportDirectory();
    final String stamp =
        DateTime.now().toIso8601String().split('T').first;
    final File file = File(p.join(directory.path, 'kairo-export-$stamp.json'));

    return file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(contents),
    );
  }

  /// Destroys every reminder, every occurrence and every preference.
  ///
  /// The default reminders are re-seeded the next time the reminder engine
  /// starts. The user's history is not.
  Future<void> deleteEverything() async {
    await _database.transaction(() async {
      await _database.delete(_database.healthReports).go();
      await _database.delete(_database.coachLines).go();
      await _database.delete(_database.reminderOccurrences).go();
      await _database.delete(_database.reminderDefinitions).go();
      await _database.delete(_database.userSettingsTable).go();
    });
  }

  /// Every row of [table], as maps of column name to value, less
  /// [_withheldColumns].
  Future<List<Map<String, Object?>>> _rowsOf(
    TableInfo<Table, Object> table,
  ) async {
    final List<QueryRow> rows = await _database
        .customSelect(
          'SELECT * FROM ${table.actualTableName}',
          readsFrom: <ResultSetImplementation<Object, Object>>{table},
        )
        .get();
    return rows
        .map(
          (QueryRow row) => <String, Object?>{
            for (final MapEntry<String, Object?> column in row.data.entries)
              if (!_withheldColumns.contains(column.key))
                column.key: column.value,
          },
        )
        .toList();
  }
}

/// The application's [KairoDataRepository].
final Provider<KairoDataRepository> dataRepositoryProvider =
    Provider<KairoDataRepository>(
  (Ref ref) => KairoDataRepository(ref.watch(databaseProvider)),
);
