import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'platform_bridge.g.dart';

/// This isolate's line to the other isolates Kairo is running.
///
/// Every Kairo window runs its own `FlutterEngine` and so its own isolate,
/// sharing nothing — not the event bus, not the database. Anything one window
/// tells another goes down to the platform and comes back up here.
///
/// The channel carries text and takes no view on what it means, so the native
/// bridge does not need rebuilding every time Kairo finds something new to say.
///
/// **One per isolate.** The receiving half is a single handler on the platform
/// channel, so a second instance takes delivery away from the first.
class KairoIsolateChannel implements KairoNativeRelay {
  /// Opens this isolate's end of the relay and starts listening.
  KairoIsolateChannel({KairoNativeRelayApi? relay})
    : _relay = relay ?? KairoNativeRelayApi() {
    KairoNativeRelay.setUp(this);
  }

  final KairoNativeRelayApi _relay;

  final StreamController<String> _received = StreamController<String>.broadcast();

  /// Everything the other isolates have sent since this was opened.
  ///
  /// Broadcast, and does not replay: a message sent while nothing was listening
  /// is gone. Kairo's messages are all about now, and a reminder delivered late
  /// is worse than one missed.
  Stream<String> get messages => _received.stream;

  /// Sends [message] to every other Kairo isolate.
  Future<void> send(String message) => _relay.relay(message);

  @override
  void onMessage(String message) {
    if (!_received.isClosed) {
      _received.add(message);
    }
  }

  /// Stops listening and closes [messages].
  Future<void> dispose() {
    KairoNativeRelay.setUp(null);
    return _received.close();
  }
}

/// This isolate's [KairoIsolateChannel].
final Provider<KairoIsolateChannel> isolateChannelProvider =
    Provider<KairoIsolateChannel>((Ref ref) {
      final KairoIsolateChannel channel = KairoIsolateChannel();
      ref.onDispose(channel.dispose);
      return channel;
    });
