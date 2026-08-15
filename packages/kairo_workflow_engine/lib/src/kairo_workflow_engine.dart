import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo_event_bus/event_bus.dart';

import 'workflow.dart';

/// Listens to the event bus and runs the workflows each event triggers.
///
/// Where Kairo decides *whether* something should happen, holding every rule
/// about when to stay out of the user's way.
///
/// Workflows matching the same event run concurrently and in no guaranteed
/// order. Two things that must happen in sequence are one workflow with two
/// actions, not two workflows.
class KairoWorkflowEngine {
  /// Creates an engine listening to [eventBus].
  KairoWorkflowEngine({required KairoEventBus eventBus}) : _eventBus = eventBus;

  final KairoEventBus _eventBus;
  final List<AnyWorkflow> _workflows = <AnyWorkflow>[];

  StreamSubscription<KairoEvent>? _subscription;

  /// Whether the engine is currently listening.
  bool get isRunning => _subscription != null;

  /// The workflows registered, in the order they were added.
  Iterable<AnyWorkflow> get workflows => _workflows;

  /// Adds [workflow] to the rules being kept.
  ///
  /// May be called before or after [start]; a workflow registered while the
  /// engine is running takes effect from the next event.
  void register(AnyWorkflow workflow) => _workflows.add(workflow);

  /// Removes every registered workflow.
  void clear() => _workflows.clear();

  /// Begins reacting to events. Calling this while already running does
  /// nothing.
  void start() {
    if (isRunning) {
      return;
    }
    _subscription = _eventBus.events.listen(_dispatch);
  }

  /// Stops reacting to events. The workflows are kept, so [start] resumes
  /// rather than restarts.
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  /// Stops the engine and forgets every workflow.
  Future<void> dispose() async {
    await stop();
    clear();
  }

  void _dispatch(KairoEvent event) {
    for (final AnyWorkflow workflow in _workflows) {
      if (workflow.matches(event)) {
        unawaited(_runGuarded(workflow, event));
      }
    }
  }

  /// Runs one workflow, keeping its failure to itself.
  ///
  /// Kairo runs for days at a time. An engine that stopped listening because
  /// one action threw would look fine and silently remind the user of nothing.
  Future<void> _runGuarded(AnyWorkflow workflow, KairoEvent event) async {
    try {
      await workflow.run(event);
    } on Object catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'kairo workflow engine',
          context: ErrorDescription(
            'running the workflow "${workflow.name}" for $event',
          ),
        ),
      );
    }
  }
}

/// The application's [KairoWorkflowEngine].
///
/// Created stopped and empty. The engines that own behaviour register their
/// workflows as they start, so what Kairo will do is assembled at launch.
final Provider<KairoWorkflowEngine> workflowEngineProvider =
    Provider<KairoWorkflowEngine>(
  (Ref ref) {
    final KairoWorkflowEngine engine = KairoWorkflowEngine(
      eventBus: ref.watch(eventBusProvider),
    );
    ref.onDispose(engine.dispose);
    return engine;
  },
);
