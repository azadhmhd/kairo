/// Water, standing, eye breaks — the reminders Kairo actually makes.
///
/// This package composes the others rather than adding machinery of its own.
/// The scheduler says when a reminder is due, the workflow engine decides
/// whether it may be shown, storage records what happened and the event bus
/// tells everyone else. What lives here is what is specifically about
/// reminders: what they are, what they say, and what the user's answer means.
library;

export 'src/default_reminders.dart';
export 'src/kairo_reminder_engine.dart';
export 'src/reminder_events.dart';
export 'src/reminder_service.dart';
