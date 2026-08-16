// The contract between Kairo's Dart code and the native window host.
//
// This file is a schema, not application code. It is never imported at
// runtime; `./scripts/generate.sh` reads it and writes both sides of the bridge:
//
//   lib/src/platform/platform_bridge.g.dart
//   ../../apps/desktop/macos/Runner/PlatformBridge.g.swift
//
// Regenerate after every change here, and commit the generated files. Editing
// either generated file by hand guarantees the two sides drift apart, which is
// the exact failure this file exists to prevent.

import 'package:pigeon/pigeon.dart';

/// How far forward a window sits in the platform's stacking order.
enum KairoNativeWindowLevel {
  /// An ordinary application window, ordered against its siblings by use.
  normal,

  /// Above ordinary windows, including those of other applications. The
  /// character and reminder popups live here.
  floating,

  /// Behind every ordinary window, pinned to the desktop.
  desktop,
}

/// A rectangle in screen coordinates, in logical pixels.
///
/// A plain class rather than Flutter's `Rect`, because the generated Swift has
/// no access to Flutter's Dart types.
class KairoNativeRect {
  KairoNativeRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  double x;
  double y;
  double width;
  double height;
}

/// Everything the platform needs in order to create a window.
///
/// Every field is required: defaults belong to `KairoWindowDescriptor`, and a
/// schema that also carried them would be a second place for them to disagree.
class KairoNativeWindowSpec {
  KairoNativeWindowSpec({
    required this.entrypoint,
    required this.width,
    required this.height,
    required this.title,
    required this.level,
    required this.transparent,
    required this.decorated,
    required this.resizable,
    required this.ignoresMouseEvents,
    required this.skipTaskbar,
    this.x,
    this.y,
  });

  /// The Dart entrypoint the window's own engine runs.
  ///
  /// Every window gets a separate `FlutterEngine`, and so a separate isolate.
  /// The named function must be annotated `@pragma('vm:entry-point')`, or the
  /// compiler will discard it from a release build.
  String entrypoint;

  /// The window's initial width, in logical pixels.
  double width;

  /// The window's initial height, in logical pixels.
  double height;

  /// The window's title.
  ///
  /// Not drawn when [decorated] is false, but still what the platform reports
  /// to accessibility tools and window lists.
  String title;

  /// Where the window sits in the stacking order.
  KairoNativeWindowLevel level;

  /// Whether the window's background is transparent rather than opaque.
  bool transparent;

  /// Whether the platform draws a title bar and frame around the window.
  bool decorated;

  /// Whether the user may resize the window.
  bool resizable;

  /// Whether clicks fall through the window to whatever is behind it.
  bool ignoresMouseEvents;

  /// Whether the window is hidden from the dock, taskbar and window switcher.
  bool skipTaskbar;

  /// The initial left edge, in screen coordinates. Centred when null.
  double? x;

  /// The initial top edge, in screen coordinates. Centred when null.
  double? y;
}

/// What Kairo asks the platform to do with windows.
///
/// Implemented natively — in Swift/AppKit on macOS, and later in Win32 and on
/// Linux. Every method is asynchronous: window operations cross to the platform
/// thread and must never block the isolate that asked.
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/platform/platform_bridge.g.dart',
    swiftOut: '../../apps/desktop/macos/Runner/PlatformBridge.g.swift',
    dartPackageName: 'kairo_desktop_engine',
  ),
)
@HostApi()
abstract class KairoNativeWindowApi {
  /// Creates a window from [spec] and returns the handle identifying it.
  ///
  /// The window is created hidden, so it can be positioned before anyone sees
  /// it. Call [showWindow] once it is ready.
  @async
  int createWindow(KairoNativeWindowSpec spec);

  /// Makes the window at [handle] visible.
  @async
  void showWindow(int handle);

  /// Hides the window at [handle] without destroying it.
  @async
  void hideWindow(int handle);

  /// Destroys the window at [handle] and shuts down its engine.
  ///
  /// The handle is invalid afterwards.
  @async
  void closeWindow(int handle);

  /// Brings the window at [handle] forward and gives it keyboard focus.
  @async
  void focusWindow(int handle);

  /// Moves and resizes the window at [handle].
  @async
  void setWindowBounds(int handle, KairoNativeRect bounds);

  /// The current position and size of the window at [handle].
  @async
  KairoNativeRect getWindowBounds(int handle);

  /// Whether the window at [handle] is currently on screen.
  ///
  /// Asked of the platform rather than remembered: it can hide a window without
  /// being told to, when the user closes it or its space goes away.
  @async
  bool isWindowVisible(int handle);

  /// Changes where the window at [handle] sits in the stacking order.
  @async
  void setWindowLevel(int handle, KairoNativeWindowLevel level);

  /// Sets whether clicks fall through the window at [handle].
  @async
  void setIgnoresMouseEvents(int handle, bool ignore);

  /// The usable area of the display the user is working on — the screen holding
  /// keyboard focus, not the one Kairo launched on.
  ///
  /// Usable excludes the menu bar and the dock, so something placed on the
  /// bottom edge of this rectangle sits on the desktop rather than behind the
  /// dock.
  @async
  KairoNativeRect activeDisplayBounds();
}

/// What Kairo asks of the operating system itself, rather than of its windows.
@HostApi()
abstract class KairoNativeSystemApi {
  /// Whether the system starts Kairo when the user logs in.
  ///
  /// Asked of the system rather than remembered: the user can revoke it in
  /// System Settings without Kairo being told.
  @async
  bool launchesAtLogin();

  /// Asks the system to start Kairo at login, or to stop doing so.
  @async
  void setLaunchAtLogin(bool enabled);
}

/// How one of Kairo's isolates reaches the others.
///
/// Kairo's windows share no memory and no event bus, so the only path between
/// them is down to the platform and back up. This is that path.
///
/// The payload is text on purpose: the platform is a postman, and should not
/// need a rebuilt bridge every time the application finds something new to say.
@HostApi()
abstract class KairoNativeRelayApi {
  /// Passes [message] to every Kairo isolate except the one that sent it.
  ///
  /// Broadcast rather than addressed. Delivery is best-effort: an isolate not
  /// yet listening misses the message rather than queueing it.
  @async
  void relay(String message);
}

/// A message from another of Kairo's isolates.
@FlutterApi()
abstract class KairoNativeRelay {
  /// Another isolate sent [message].
  void onMessage(String message);
}

/// What the platform reports back about windows.
///
/// These arrive because the user or the operating system did something, not
/// because Kairo asked. The desktop engine translates them into events on the
/// bus.
@FlutterApi()
abstract class KairoNativeWindowEvents {
  /// The window at [handle] was closed, by the user or by the platform.
  void onWindowClosed(int handle);

  /// The window at [handle] gained or lost keyboard focus.
  void onWindowFocusChanged(int handle, bool focused);

  /// The window at [handle] was moved or resized, and now occupies [bounds].
  void onWindowMoved(int handle, KairoNativeRect bounds);
}
