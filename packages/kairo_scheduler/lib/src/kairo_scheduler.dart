import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo_event_bus/event_bus.dart';

import 'kairo_schedule.dart';
import 'schedule_due_event.dart';

/// Watches the clock and announces schedules as they come due.
///
/// One timer serves every schedule: it wakes on [tick], compares the clock to
/// what each schedule is owed, and publishes a [ScheduleDueEvent] for anything
/// that has arrived. Schedules are therefore accurate to within one tick, which
/// is cheaper than a timer each and finer than a user can perceive.
///
/// The scheduler knows only *when*. Whether a reminder should actually be shown
/// is the workflow engine's decision, which is what keeps quiet hours from
/// being understood in two places.
class KairoScheduler {
  /// Creates a scheduler publishing to [eventBus].
  ///
  /// [now] lets the clock be driven from outside, so behaviour that would
  /// otherwise take an hour to observe can be stepped through by hand.
  KairoScheduler({
    required KairoEventBus eventBus,
    DateTime Function()? now,
    this.tick = const Duration(seconds: 30),
  })  : _eventBus = eventBus,
        _now = now ?? DateTime.now;

  final KairoEventBus _eventBus;
  final DateTime Function() _now;

  /// How often the clock is consulted.
  final Duration tick;

  final Map<String, KairoSchedule> _schedules = <String, KairoSchedule>{};
  final Map<String, DateTime> _dueAt = <String, DateTime>{};

  Timer? _timer;

  /// Whether the scheduler is currently watching the clock.
  bool get isRunning => _timer != null;

  /// The schedules being kept, in no particular order.
  Iterable<KairoSchedule> get schedules => _schedules.values;

  /// Adds [schedule], replacing any schedule already using its id.
  ///
  /// The countdown starts now, so adding a 45-minute reminder does not fire it
  /// immediately on every launch.
  void add(KairoSchedule schedule) {
    _schedules[schedule.id] = schedule;
    _dueAt[schedule.id] = schedule.nextAfter(_now());
  }

  /// Stops keeping the schedule [id]. Does nothing if it was not being kept.
  void remove(String id) {
    _schedules.remove(id);
    _dueAt.remove(id);
  }

  /// Forgets every schedule.
  void clear() {
    _schedules.clear();
    _dueAt.clear();
  }

  /// When [id] is next due, or null if it is not being kept.
  DateTime? dueAt(String id) => _dueAt[id];

  /// The schedule kept under [id], or null if there is none.
  ///
  /// Lets a caller check whether a schedule already matches before calling
  /// [add], which restarts the countdown — re-adding an unchanged schedule
  /// would push its next firing away every time anything else was edited.
  KairoSchedule? scheduleFor(String id) => _schedules[id];

  /// Moves the next firing of [id] to [at], leaving its rhythm alone. This is
  /// what snoozing is. Does nothing if [id] is not being kept.
  void rescheduleTo(String id, DateTime at) {
    if (_schedules.containsKey(id)) {
      _dueAt[id] = at;
    }
  }

  /// Begins watching the clock. Calling this while already running does
  /// nothing.
  void start() {
    if (isRunning) {
      return;
    }
    _timer = Timer.periodic(tick, (Timer _) => _check());
  }

  /// Stops watching the clock. The schedules are kept, so [start] resumes
  /// rather than restarts.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Stops the scheduler and forgets everything.
  void dispose() {
    stop();
    clear();
  }

  /// Consults the clock once, publishing anything that has come due.
  ///
  /// Called on every tick. Public so a check can be forced on demand — after
  /// waking from sleep, for instance.
  void checkNow() => _check();

  void _check() {
    final DateTime now = _now();

    for (final KairoSchedule schedule in _schedules.values.toList()) {
      final DateTime? due = _dueAt[schedule.id];
      if (due == null || now.isBefore(due)) {
        continue;
      }

      // Measured from now, not from the firing just missed: a machine that
      // slept through four intervals owes one reminder, not a burst of four.
      //
      // ponytail: skipping missed intervals is the right call for reminders. A
      // schedule that must not lose firings — a nightly database vacuum, say —
      // would need to carry a catch-up flag.
      _dueAt[schedule.id] = schedule.nextAfter(now);
      _eventBus.publish(ScheduleDueEvent(schedule.id, due));
    }
  }
}

/// The application's [KairoScheduler].
///
/// Created stopped. `bootstrap` starts it last, once its listeners are
/// themselves listening, so the first tick is never published into an empty bus.
final Provider<KairoScheduler> schedulerProvider = Provider<KairoScheduler>(
  (Ref ref) {
    final KairoScheduler scheduler = KairoScheduler(
      eventBus: ref.watch(eventBusProvider),
    );
    ref.onDispose(scheduler.dispose);
    return scheduler;
  },
);
