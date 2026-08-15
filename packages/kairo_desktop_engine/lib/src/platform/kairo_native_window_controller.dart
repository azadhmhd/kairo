import 'package:flutter/widgets.dart';

import '../window/kairo_window_controller.dart';
import '../window/kairo_window_descriptor.dart';
import 'platform_bridge.g.dart';

/// Drives one natively created window through the platform bridge.
///
/// The window lives on the native side; this holds only its handle. Everything
/// above [KairoWindowController] therefore treats a transparent character
/// window and the main dashboard window alike.
class KairoNativeWindowController implements KairoWindowController {
  /// Creates a controller for the window at [handle].
  const KairoNativeWindowController(this._api, this.handle);

  final KairoNativeWindowApi _api;

  /// The platform's identifier for this window.
  final int handle;

  @override
  Future<void> show() => _api.showWindow(handle);

  @override
  Future<void> hide() => _api.hideWindow(handle);

  @override
  Future<void> focus() => _api.focusWindow(handle);

  @override
  Future<void> close() => _api.closeWindow(handle);

  @override
  Future<bool> isVisible() => _api.isWindowVisible(handle);

  @override
  Future<Rect> bounds() async {
    final KairoNativeRect rect = await _api.getWindowBounds(handle);
    return Rect.fromLTWH(rect.x, rect.y, rect.width, rect.height);
  }

  /// Moves the window, keeping the size the platform currently reports.
  ///
  /// The bridge sets position and size together — changing one then the other
  /// makes the window visibly jump — so the current bounds are read first.
  @override
  Future<void> move(Offset position) async {
    final Rect current = await bounds();
    await _api.setWindowBounds(
      handle,
      KairoNativeRect(
        x: position.dx,
        y: position.dy,
        width: current.width,
        height: current.height,
      ),
    );
  }

  @override
  Future<void> resize(Size size) async {
    final Rect current = await bounds();
    await _api.setWindowBounds(
      handle,
      KairoNativeRect(
        x: current.left,
        y: current.top,
        width: size.width,
        height: size.height,
      ),
    );
  }

  /// Sets whether clicks fall through this window.
  ///
  /// Deliberately not part of [KairoWindowController]: only a window made
  /// transparent to the mouse has anything to say about it, and the main window
  /// never does.
  Future<void> setIgnoresMouseEvents({required bool ignore}) =>
      _api.setIgnoresMouseEvents(handle, ignore);
}

/// Translates a [KairoWindowDescriptor] into what the platform needs.
///
/// A straight mapping with no decisions in it; defaults live on the descriptor.
/// [KairoWindowDescriptor.alwaysOnTop] becomes a window level, the platform's
/// way of saying the same thing with more than two answers.
KairoNativeWindowSpec specFor(KairoWindowDescriptor descriptor) {
  return KairoNativeWindowSpec(
    entrypoint: descriptor.entrypoint ?? 'main',
    width: descriptor.size.width,
    height: descriptor.size.height,
    title: descriptor.title,
    level: descriptor.alwaysOnTop
        ? KairoNativeWindowLevel.floating
        : KairoNativeWindowLevel.normal,
    transparent: descriptor.transparent,
    decorated: descriptor.decorated,
    resizable: descriptor.resizable,
    ignoresMouseEvents: descriptor.ignoresMouseEvents,
    skipTaskbar: descriptor.skipTaskbar,
    x: descriptor.position?.dx,
    y: descriptor.position?.dy,
  );
}
