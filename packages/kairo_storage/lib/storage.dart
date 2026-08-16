/// Kairo's local database, and the repositories that read and write it.
///
/// The only code in Kairo that speaks SQL. Callers ask a repository for models
/// from `kairo_shared_models` and never see a row, a query or a connection.
///
/// The table definitions are deliberately not exported: a caller that could
/// reach them could write a query, and then this would not be the only place
/// that does.
library;

export 'src/database/kairo_database.dart';
export 'src/repositories/coach_repository.dart';
export 'src/repositories/health_report_repository.dart';
export 'src/repositories/kairo_data_repository.dart';
export 'src/repositories/reminder_repository.dart';
export 'src/repositories/reminder_stats_repository.dart';
export 'src/repositories/settings_repository.dart';
