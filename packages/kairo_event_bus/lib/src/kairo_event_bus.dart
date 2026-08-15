import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'kairo_event.dart';

/// Carries [KairoEvent]s from whoever publishes them to whoever cares.
///
/// Features depend on the bus rather than on each other, so adding a listener
/// changes nothing about the publisher.
///
/// ## This bus reaches one isolate only
///
/// Every Kairo window runs its own `FlutterEngine`, and so its own isolate with
/// its own heap. An event published in the main window is **not** visible in
/// the character window. Crossing that boundary is the platform bridge's job —
/// the native side is the only thing both isolates can see.
class KairoEventBus {
  final StreamController<KairoEvent> _controller =
      StreamController<KairoEvent>.broadcast();

  /// Every event published to this bus, in the order it was published.
  Stream<KairoEvent> get events => _controller.stream;

  /// Whether [dispose] has been called.
  bool get isDisposed => _controller.isClosed;

  /// Announces that [event] happened.
  ///
  /// Listeners are notified asynchronously, so a slow subscriber cannot stall
  /// the publisher. Throws a [StateError] if the bus has been disposed, rather
  /// than silently reaching nobody.
  void publish(KairoEvent event) {
    if (_controller.isClosed) {
      throw StateError(
        'Cannot publish $event: this event bus has been disposed.',
      );
    }
    _controller.add(event);
  }

  /// Only the events of type [T]. How nearly every subscriber should listen.
  Stream<T> on<T extends KairoEvent>() => _controller.stream.where(
    (KairoEvent event) => event is T,
  ).cast<T>();

  /// Closes the bus and ends every subscription to it.
  Future<void> dispose() => _controller.close();
}

/// The application's [KairoEventBus].
///
/// One per container, which is one per isolate — matching the bus's actual
/// reach. Closed with the container that made it.
final Provider<KairoEventBus> eventBusProvider = Provider<KairoEventBus>((
  Ref ref,
) {
  final KairoEventBus bus = KairoEventBus();
  ref.onDispose(bus.dispose);
  return bus;
});
