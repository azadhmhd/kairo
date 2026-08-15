import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo_event_bus/event_bus.dart';
import 'package:kairo_scheduler/scheduler.dart';
import 'package:kairo_shared_models/shared_models.dart';
import 'package:kairo_storage/storage.dart';

import 'reminder_events.dart';

/// What the user can do about a reminder they have been shown.
///
/// Every answer is written down before it is announced, so anything reacting by
/// reading the history sees the answer that prompted it.
class ReminderService {
  /// Creates a service recording answers to [reminders].
  const ReminderService({
    required ReminderRepository reminders,
    required KairoScheduler scheduler,
    required KairoEventBus eventBus,
    DateTime Function() now = DateTime.now,
  })  : _reminders = reminders,
        _scheduler = scheduler,
        _eventBus = eventBus,
        _now = now;

  /// How long a reminder waits when snoozed without a stated delay.
  static const Duration defaultSnooze = Duration(minutes: 5);

  final ReminderRepository _reminders;
  final KairoScheduler _scheduler;
  final KairoEventBus _eventBus;
  final DateTime Function() _now;

  /// Records that the user did what the reminder asked.
  Future<void> complete(ReminderOccurrence occurrence) =>
      _answer(occurrence, ReminderOutcome.completed);

  /// Records that the user wants the reminder back shortly, and brings it back.
  ///
  /// It returns after [delay], then resumes its usual interval measured from
  /// there, so snoozing does not double the rate at which it arrives.
  Future<void> snooze(
    ReminderOccurrence occurrence, {
    Duration delay = defaultSnooze,
  }) async {
    final DateTime? answeredAt =
        await _answer(occurrence, ReminderOutcome.snoozed);
    if (answeredAt == null) {
      return;
    }
    _scheduler.rescheduleTo(occurrence.definitionId, answeredAt.add(delay));
  }

  /// Records that the user waved the reminder away.
  Future<void> dismiss(ReminderOccurrence occurrence) =>
      _answer(occurrence, ReminderOutcome.dismissed);

  /// Writes [outcome] against [occurrence] and announces it.
  ///
  /// Returns when the answer was recorded, or null if there was nothing to
  /// record. An already-answered occurrence is left untouched: a second click
  /// on Done is the same click, and counting it twice would inflate the streak.
  Future<DateTime?> _answer(
    ReminderOccurrence occurrence,
    ReminderOutcome outcome,
  ) async {
    if (occurrence.isAnswered) {
      return null;
    }

    final DateTime at = _now();
    await _reminders.recordOutcome(occurrence.id, outcome, at);
    _eventBus.publish(
      ReminderAnsweredEvent(occurrence.answered(outcome, at)),
    );
    return at;
  }
}

/// The application's [ReminderService].
final Provider<ReminderService> reminderServiceProvider =
    Provider<ReminderService>(
  (Ref ref) => ReminderService(
    reminders: ref.watch(reminderRepositoryProvider),
    scheduler: ref.watch(schedulerProvider),
    eventBus: ref.watch(eventBusProvider),
  ),
);
