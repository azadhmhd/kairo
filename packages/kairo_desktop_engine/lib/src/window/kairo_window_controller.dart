import 'package:flutter/widgets.dart';

/// What every Kairo window can be asked to do.
///
/// Two mechanisms implement this — `window_manager` for the window the
/// application launched into, the native bridge for every window Kairo creates
/// — and the application layer cannot tell them apart.
///
/// Minimising is deliberately absent: it belongs to a window that lives in the
/// dock, which a borderless character window does not.
abstract interface class KairoWindowController {
  /// Makes the window visible.
  Future<void> show();

  /// Hides the window without destroying it, so [show] can bring it back.
  Future<void> hide();

  /// Brings the window forward and gives it keyboard focus.
  Future<void> focus();

  /// Closes the window.
  Future<void> close();

  /// Moves the window's top-left corner to [position], in logical pixels.
  Future<void> move(Offset position);

  /// Resizes the window to [size], in logical pixels.
  Future<void> resize(Size size);

  /// The window's current position and size, in logical pixels.
  Future<Rect> bounds();

  /// Whether the window is currently on screen.
  Future<bool> isVisible();
}
