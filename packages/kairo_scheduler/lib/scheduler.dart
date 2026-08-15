/// Kairo's time engine: it knows when something is due and announces it.
///
/// It does not know what is due, whether it should happen, or what the user
/// will see — those belong to the reminder engine, the workflow engine and the
/// desktop engine in turn.
///
/// Scheduling is not reminder-specific, which is why this is its own package:
/// daily summaries and database maintenance need the same thing.
library;

export 'src/kairo_schedule.dart';
export 'src/kairo_scheduler.dart';
export 'src/schedule_due_event.dart';
