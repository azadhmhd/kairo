import 'package:drift/drift.dart';
import 'package:kairo_shared_models/shared_models.dart';

/// The reminders the user has asked Kairo to keep making.
///
/// Mirrors [ReminderDefinition]. A [Duration] is stored as whole seconds and a
/// [DailyWindow] as its two minute-of-day ends, so every column is a value
/// SQLite compares and sorts natively.
@DataClassName('ReminderDefinitionRow')
class ReminderDefinitions extends Table {
  /// Identifies the reminder.
  TextColumn get id => text()();

  /// Which [ReminderKind] this is, stored by name so the column stays readable.
  TextColumn get kind => textEnum<ReminderKind>()();

  /// What the user is shown when it fires.
  TextColumn get label => text()();

  /// How long Kairo waits between firings, in seconds.
  IntColumn get intervalSeconds => integer()();

  /// The first minute of the day this may fire, or null for all day.
  IntColumn get activeFromMinute => integer().nullable()();

  /// The minute of the day it stops firing, or null for all day.
  IntColumn get activeToMinute => integer().nullable()();

  /// Whether the reminder is currently being made.
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Every firing of every reminder, and what the user did about it.
///
/// Mirrors [ReminderOccurrence]. This table is the whole of Kairo's history;
/// reports are counted from it and nothing else.
@DataClassName('ReminderOccurrenceRow')
class ReminderOccurrences extends Table {
  /// Identifies this firing.
  TextColumn get id => text()();

  /// The reminder this came from.
  ///
  /// Deleting a definition takes its history with it, because a completion
  /// rate for a reminder the user no longer has is not a number worth showing.
  TextColumn get definitionId =>
      text().references(ReminderDefinitions, #id, onDelete: KeyAction.cascade)();

  /// When Kairo decided it was time.
  DateTimeColumn get dueAt => dateTime()();

  /// What became of it, stored by name.
  TextColumn get outcome => textEnum<ReminderOutcome>()();

  /// When the user answered, or null while still pending.
  DateTimeColumn get respondedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// The user's preferences.
///
/// Mirrors [UserSettings]. Exactly one row ever exists, at [settingsRowId] —
/// a table rather than a file so that settings are read and written the same
/// way as everything else, inside the same transaction and the same backup.
@DataClassName('UserSettingsRow')
class UserSettingsTable extends Table {
  /// Always [settingsRowId]. Present so the row can be upserted by key.
  IntColumn get id => integer()();

  /// The first minute of the day Kairo stays silent, or null for none.
  IntColumn get quietFromMinute => integer().nullable()();

  /// The minute of the day it stops being silent, or null for none.
  IntColumn get quietToMinute => integer().nullable()();

  /// Whether Kairo starts when the user logs in.
  BoolColumn get launchAtLogin => boolean().withDefault(const Constant(false))();

  /// Whether the character is shown on the desktop.
  BoolColumn get characterEnabled =>
      boolean().withDefault(const Constant(true))();

  /// Whether reminders make a sound.
  BoolColumn get soundEnabled => boolean().withDefault(const Constant(true))();

  BoolColumn get aiEnabled => boolean().withDefault(const Constant(false))();

  TextColumn get aiBaseUrl =>
      text().withDefault(const Constant(AiSettings.ollamaBaseUrl))();

  TextColumn get aiModel => text().withDefault(const Constant(''))();

  /// The bearer token, or empty for a local model. ponytail: plaintext because
  /// this file never leaves the machine; keychain when Kairo grows a sync.
  TextColumn get aiApiKey => text().withDefault(const Constant(''))();

  IntColumn get aiReportSeconds =>
      integer().withDefault(const Constant(24 * 60 * 60))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// The primary key of the single row in [UserSettingsTable].
const int settingsRowId = 0;

/// What Kairo says for a reminder instead of the user's own wording. Separate
/// from [ReminderDefinitions] so it can never overwrite what the user typed.
@DataClassName('CoachLineRow')
class CoachLines extends Table {
  TextColumn get definitionId =>
      text().references(ReminderDefinitions, #id, onDelete: KeyAction.cascade)();

  TextColumn get message => text()();

  TextColumn get stance => textEnum<CoachStance>()();

  DateTimeColumn get generatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{definitionId};
}

/// What the character says as it walks off. Several per outcome, so the same
/// answer is not met with the same words every time.
@DataClassName('CoachReactionRow')
class CoachReactions extends Table {
  TextColumn get outcome => textEnum<ReminderOutcome>()();

  TextColumn get message => text()();

  DateTimeColumn get generatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{outcome, message};
}

/// A written summary, keyed by when it was written — the user chooses how
/// often that is, and it can be several times an hour.
@DataClassName('HealthReportRow')
class HealthReports extends Table {
  DateTimeColumn get generatedAt => dateTime()();

  TextColumn get body => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{generatedAt};
}
