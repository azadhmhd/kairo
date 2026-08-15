import 'package:kairo_event_bus/event_bus.dart';

/// Decides whether a workflow should act on the event that triggered it.
///
/// Conditions must stay synchronous and side-effect free. One that has to read
/// the database is really an action wearing the wrong hat.
typedef WorkflowCondition<T extends KairoEvent> = bool Function(T event);

/// Something a workflow does once its conditions have passed.
typedef WorkflowAction<T extends KairoEvent> = Future<void> Function(T event);

/// A workflow with its event type erased.
///
/// Exists only so the engine can hold workflows triggering on different events
/// in one list: Dart cannot express "a list of `Workflow<T>` for any T". Not an
/// extension point — there is one implementation and there should stay one.
abstract interface class AnyWorkflow {
  /// What this workflow is called, used when reporting a failure.
  String get name;

  /// Whether [event] is the kind this workflow triggers on.
  bool matches(KairoEvent event);

  /// Runs the workflow against [event], which [matches] has already accepted.
  Future<void> run(KairoEvent event);
}

/// A trigger, some conditions, and the actions to take when they pass.
///
/// This is the shape every Kairo behaviour is written in:
///
/// ```dart
/// Workflow<ScheduleDueEvent>(
///   name: 'water reminder',
///   when: <WorkflowCondition<ScheduleDueEvent>>[isWaterSchedule, notQuietHours],
///   then: <WorkflowAction<ScheduleDueEvent>>[announceReminderDue],
/// )
/// ```
///
/// Conditions and actions are Dart functions, deliberately: a serialised rule
/// format would need a parser, a condition registry and a versioning story to
/// say what Dart already says with a compiler checking it.
class Workflow<T extends KairoEvent> implements AnyWorkflow {
  /// Creates a workflow triggered by events of type [T].
  ///
  /// Every condition in [when] must pass, in order, before any action in
  /// [then] runs. A workflow with no conditions always acts.
  const Workflow({
    required this.name,
    required this.then,
    this.when = const <Never>[],
  });

  @override
  final String name;

  /// What must be true before this workflow acts. Checked in order, and the
  /// first one to answer false stops the rest from being asked.
  final List<WorkflowCondition<T>> when;

  /// What this workflow does. Run in order, each awaited before the next.
  final List<WorkflowAction<T>> then;

  @override
  bool matches(KairoEvent event) => event is T;

  @override
  Future<void> run(KairoEvent event) async {
    final T triggering = event as T;

    for (final WorkflowCondition<T> condition in when) {
      if (!condition(triggering)) {
        return;
      }
    }

    for (final WorkflowAction<T> action in then) {
      await action(triggering);
    }
  }

  @override
  String toString() => 'Workflow<$T>($name)';
}
