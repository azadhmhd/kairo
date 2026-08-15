import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// The generated part below refers to ReminderKind and ReminderOutcome by name,
// because the columns are declared with `textEnum`. A part sees only what its
// own library imports, so importing the models here is what puts them in scope
// for generated code that never mentions where they came from.
import 'package:kairo_shared_models/shared_models.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'kairo_database.g.dart';

/// Kairo's local database: one SQLite file on the user's machine, and the only
/// place Kairo keeps anything.
@DriftDatabase(
  tables: <Type>[ReminderDefinitions, ReminderOccurrences, UserSettingsTable],
)
class KairoDatabase extends _$KairoDatabase {
  /// Opens the database in the application's support directory.
  KairoDatabase() : super(_openOnDisk());

  /// Opens a database that lives only as long as this object, for running
  /// against a clean slate without disturbing the real file.
  KairoDatabase.inMemory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        beforeOpen: (OpeningDetails details) async {
          // Drift leaves foreign keys off unless asked, and this schema relies
          // on them to take a reminder's history with it when it is deleted.
          await customStatement('PRAGMA foreign_keys = ON');

          // Write-ahead logging, so a reader is never blocked by a writer. On
          // the default journal two Kairo processes contend on every write and
          // one eventually fails with "database is locked".
          await customStatement('PRAGMA journal_mode = WAL');

          // Five seconds is far longer than any write Kairo makes, so hitting
          // this timeout means genuine contention rather than slowness.
          await customStatement('PRAGMA busy_timeout = 5000');
        },
      );

  /// Where the database file lives.
  static Future<File> file() async {
    final Directory directory = await getApplicationSupportDirectory();
    return File(p.join(directory.path, 'kairo.sqlite'));
  }

  static QueryExecutor _openOnDisk() {
    return LazyDatabase(() async => NativeDatabase.createInBackground(await file()));
  }
}

/// The application's [KairoDatabase].
///
/// Held open for the life of the application: opening SQLite is cheap but not
/// free, and every repository shares the one connection.
final Provider<KairoDatabase> databaseProvider = Provider<KairoDatabase>(
  (Ref ref) {
    final KairoDatabase database = KairoDatabase();
    ref.onDispose(database.close);
    return database;
  },
);
