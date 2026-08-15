import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo_shared_models/shared_models.dart';

import '../database/kairo_database.dart';
import '../database/tables.dart';

/// Reads and writes the user's preferences.
///
/// There is exactly one settings row, and none at all until the user changes
/// something. Reading returns [UserSettings.defaults] rather than an absence.
class SettingsRepository {
  /// Creates a repository backed by [_database].
  const SettingsRepository(this._database);

  final KairoDatabase _database;

  /// The user's current settings, or the defaults if they have set nothing.
  Future<UserSettings> read() async {
    final UserSettingsRow? row = await (_database
            .select(_database.userSettingsTable)
          ..where(($UserSettingsTableTable t) => t.id.equals(settingsRowId)))
        .getSingleOrNull();
    return row == null ? UserSettings.defaults : _toSettings(row);
  }

  /// Emits the settings now, and again whenever they change.
  Stream<UserSettings> watch() {
    return (_database.select(_database.userSettingsTable)
          ..where(($UserSettingsTableTable t) => t.id.equals(settingsRowId)))
        .watchSingleOrNull()
        .map((UserSettingsRow? row) =>
            row == null ? UserSettings.defaults : _toSettings(row));
  }

  /// Saves [settings], replacing whatever was there.
  Future<void> write(UserSettings settings) {
    return _database.into(_database.userSettingsTable).insertOnConflictUpdate(
          UserSettingsTableCompanion.insert(
            // SQLite treats an integer primary key as an alias for the row id,
            // so Drift makes the column optional on insert. Kairo always sets
            // it: there is exactly one settings row, and it is always this one.
            id: const Value<int>(settingsRowId),
            quietFromMinute: Value<int?>(settings.quietHours?.from),
            quietToMinute: Value<int?>(settings.quietHours?.to),
            launchAtLogin: Value<bool>(settings.launchAtLogin),
            characterEnabled: Value<bool>(settings.characterEnabled),
            soundEnabled: Value<bool>(settings.soundEnabled),
          ),
        );
  }

  UserSettings _toSettings(UserSettingsRow row) {
    return UserSettings(
      quietHours: row.quietFromMinute == null || row.quietToMinute == null
          ? null
          : DailyWindow(from: row.quietFromMinute!, to: row.quietToMinute!),
      launchAtLogin: row.launchAtLogin,
      characterEnabled: row.characterEnabled,
      soundEnabled: row.soundEnabled,
    );
  }
}

/// The application's [SettingsRepository].
final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>(
  (Ref ref) => SettingsRepository(ref.watch(databaseProvider)),
);
