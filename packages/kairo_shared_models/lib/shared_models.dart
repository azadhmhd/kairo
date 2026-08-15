/// Data shared between Kairo's engines, its storage and its screens.
///
/// Everything here is an immutable value. Rules about when a reminder is due,
/// or whether it may fire, live in the engine that owns them.
library;

export 'src/daily_window.dart';
export 'src/reminder_definition.dart';
export 'src/reminder_occurrence.dart';
export 'src/tallies.dart';
export 'src/user_settings.dart';
