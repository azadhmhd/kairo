import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo_event_bus/event_bus.dart';

import '../platform/kairo_native_window_controller.dart';
import '../platform/platform_bridge.g.dart';
import '../window/kairo_window_controller.dart';
import '../window/kairo_window_descriptor.dart';
import '../window/kairo_window_id.dart';
import '../window/kairo_window_registry.dart';
import '../window/kairo_window_service.dart';
import 'kairo_window_event.dart';

/// The entry point to Kairo's desktop shell, and the owner of every window.
///
/// `bootstrap` awaits [initialize] before the first frame is scheduled; every
/// further window is created through [openWindow]. The desktop engine answers
/// *where a surface exists* — an engine that drives a surface's behaviour, such
/// as `kairo_character_engine`, never creates a window of its own.
///
/// Two windowing mechanisms sit underneath. The launch window already exists by
/// the time Dart runs and `window_manager` shapes it fine; windows Kairo makes
/// go through the native bridge, because nothing off the shelf produces a
/// transparent, click-through, always-on-top window. Both arrive at the same
/// [KairoWindowController].
class KairoDesktopEngine implements KairoNativeWindowEvents {
  /// Creates an engine that drives [windowService], records the windows it
  /// brings up in [registry], and announces them on [eventBus].
  KairoDesktopEngine({
    required this.windowService,
    required this.registry,
    required this.eventBus,
    KairoNativeWindowApi? nativeWindows,
  }) : _nativeWindows = nativeWindows ?? KairoNativeWindowApi();

  /// The service used to control the main window.
  final KairoWindowService windowService;

  /// Where the windows this engine creates become reachable by identity.
  final KairoWindowRegistry registry;

  /// Where this engine announces what happened to its windows.
  final KairoEventBus eventBus;

  final KairoNativeWindowApi _nativeWindows;

  /// Which window each platform handle belongs to. The platform reports events
  /// by handle; this turns one back into the identity Kairo uses.
  final Map<int, KairoWindowId> _idsByHandle = <int, KairoWindowId>{};

  /// Brings the desktop shell up and shows the window it describes.
  ///
  /// The order matters: the window is shaped, then registered, then announced.
  /// A listener reacting to [KairoWindowOpened] can therefore resolve the
  /// window it was told about.
  Future<void> initialize(KairoWindowDescriptor descriptor) async {
    await windowService.applyStartupDescriptor(descriptor);
    registry.register(descriptor.id, windowService);
    eventBus.publish(KairoWindowOpened(descriptor.id));
  }

  /// Creates the window [descriptor] describes and puts it on screen.
  ///
  /// Created hidden and shown once positioned, so it never appears in the wrong
  /// place first. Throws a [StateError] if that window is already open.
  ///
  /// Returns the native controller rather than the interface: only a window
  /// Kairo made can be told to stop ignoring the mouse, which the character
  /// needs while it is asking something.
  Future<KairoNativeWindowController> openWindow(
    KairoWindowDescriptor descriptor,
  ) async {
    _listenToThePlatform();

    final int handle = await _nativeWindows.createWindow(specFor(descriptor));
    final KairoNativeWindowController controller =
        KairoNativeWindowController(_nativeWindows, handle);

    _idsByHandle[handle] = descriptor.id;
    registry.register(descriptor.id, controller);

    await controller.show();
    eventBus.publish(KairoWindowOpened(descriptor.id));

    return controller;
  }

  /// The usable area of the display the user is working on.
  ///
  /// Asked every time rather than cached: the answer changes as the user moves
  /// between screens, and a stale one puts the character on the wrong display.
  Future<Rect> activeDisplayBounds() async {
    final KairoNativeRect bounds = await _nativeWindows.activeDisplayBounds();
    return Rect.fromLTWH(bounds.x, bounds.y, bounds.width, bounds.height);
  }

  /// Closes the window [id], if it is open.
  ///
  /// Does nothing when that window does not exist: the desired end state
  /// already holds. The bookkeeping happens in [onWindowClosed], because the
  /// platform reports the closure whether Kairo asked for it or not.
  Future<void> closeWindow(KairoWindowId id) async {
    final KairoWindowController? controller = registry.maybeController(id);
    if (controller != null) {
      await controller.close();
    }
  }

  /// Starts accepting what the platform reports about windows.
  ///
  /// Done on the first [openWindow] rather than at startup: until Kairo creates
  /// a window of its own the platform has nothing to report, and this keeps
  /// [initialize] free of platform channels.
  void _listenToThePlatform() {
    if (_listening) {
      return;
    }
    KairoNativeWindowEvents.setUp(this);
    _listening = true;
  }

  bool _listening = false;

  @override
  void onWindowClosed(int handle) {
    final KairoWindowId? id = _idsByHandle.remove(handle);
    if (id == null) {
      return;
    }
    registry.unregister(id);
    eventBus.publish(KairoWindowClosed(id));
  }

  // Accepted and dropped: the platform reports focus and movement for every
  // window it owns, and nothing in Kairo listens for either yet.

  @override
  void onWindowFocusChanged(int handle, bool focused) {}

  @override
  void onWindowMoved(int handle, KairoNativeRect bounds) {}
}

/// The application's [KairoDesktopEngine].
final Provider<KairoDesktopEngine> desktopEngineProvider =
    Provider<KairoDesktopEngine>(
      (Ref ref) => KairoDesktopEngine(
        windowService: ref.watch(windowServiceProvider),
        registry: ref.watch(windowRegistryProvider),
        eventBus: ref.watch(eventBusProvider),
      ),
    );
