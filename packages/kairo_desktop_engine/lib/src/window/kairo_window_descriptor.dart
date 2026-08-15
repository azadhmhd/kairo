import 'package:flutter/widgets.dart';

import 'kairo_window_id.dart';

/// Everything needed to bring a window into existence.
///
/// A value class rather than a handful of arguments, so a window's identity and
/// shape live in one place and can be compared.
@immutable
class KairoWindowDescriptor {
  /// Describes a window.
  const KairoWindowDescriptor({
    required this.id,
    required this.size,
    required this.minimumSize,
    required this.title,
    this.entrypoint,
    this.position,
    this.center = true,
    this.resizable = true,
    this.alwaysOnTop = false,
    this.skipTaskbar = false,
    this.transparent = false,
    this.decorated = true,
    this.ignoresMouseEvents = false,
  });

  /// The dashboard window Kairo opens with.
  ///
  /// Has no [entrypoint]: the platform creates it from `main` before Dart runs,
  /// rather than Kairo asking for it later.
  static const KairoWindowDescriptor mainWindow = KairoWindowDescriptor(
    id: KairoWindowId.main,
    size: Size(1100, 720),
    minimumSize: Size(880, 600),
    title: 'Kairo',
  );

  /// The window the character stands in.
  ///
  /// Every flag below is chosen so it stops looking like a window: no frame, no
  /// background, above other applications, out of the window list, and
  /// transparent to the mouse.
  ///
  /// Sized once for the character plus its speech bubble and never resized —
  /// growing a transparent always-on-top window shows up as a flicker, and the
  /// empty part costs nothing while the mouse falls through it.
  static const KairoWindowDescriptor characterWindow = KairoWindowDescriptor(
    id: KairoWindowId.character,
    entrypoint: characterEntrypoint,
    size: Size(560, 320),
    minimumSize: Size(560, 320),
    title: 'Kairo',
    resizable: false,
    alwaysOnTop: true,
    skipTaskbar: true,
    transparent: true,
    decorated: false,
    ignoresMouseEvents: true,
  );

  /// The name of the Dart function the character window's engine runs.
  ///
  /// Must match a function annotated `@pragma('vm:entry-point')` in the
  /// application, or the compiler discards it from a release build and the
  /// window comes up blank.
  static const String characterEntrypoint = 'characterWindowMain';

  /// Which window this describes.
  final KairoWindowId id;

  /// The Dart entrypoint this window's own engine runs.
  ///
  /// Null for the window the application started in. Every other window gets a
  /// separate `FlutterEngine`, and so a separate isolate.
  final String? entrypoint;

  /// The size the window is given when it first appears, in logical pixels.
  final Size size;

  /// Where the window's top-left corner goes, in screen coordinates.
  ///
  /// Null centres it on the display it opens on. Only windows Kairo creates
  /// itself can be placed this way; the launch window uses [center] instead.
  ///
  /// A position usually depends on the display size, which is unknown until the
  /// application runs — [at] is how an otherwise-constant descriptor gets one.
  final Offset? position;

  /// The smallest size the user may resize the window to, in logical pixels.
  final Size minimumSize;

  /// The window's title, shown in the title bar and the platform window list.
  final String title;

  /// Whether the window is centred on the display it opens on.
  final bool center;

  /// Whether the user may resize the window.
  final bool resizable;

  /// Whether the window floats above windows belonging to other applications.
  final bool alwaysOnTop;

  /// Whether the window is hidden from the dock, taskbar and window switcher.
  final bool skipTaskbar;

  /// Whether the window's background is transparent rather than opaque.
  final bool transparent;

  /// Whether the platform draws a title bar and frame around the window.
  final bool decorated;

  /// Whether clicks fall through the window to whatever is behind it.
  final bool ignoresMouseEvents;

  /// Returns a copy of this descriptor placed at [position]. The one thing a
  /// descriptor learns at runtime, since it depends on the display.
  KairoWindowDescriptor at(Offset position) => KairoWindowDescriptor(
    id: id,
    entrypoint: entrypoint,
    size: size,
    minimumSize: minimumSize,
    title: title,
    position: position,
    center: center,
    resizable: resizable,
    alwaysOnTop: alwaysOnTop,
    skipTaskbar: skipTaskbar,
    transparent: transparent,
    decorated: decorated,
    ignoresMouseEvents: ignoresMouseEvents,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is KairoWindowDescriptor &&
        other.id == id &&
        other.entrypoint == entrypoint &&
        other.size == size &&
        other.minimumSize == minimumSize &&
        other.title == title &&
        other.position == position &&
        other.center == center &&
        other.resizable == resizable &&
        other.alwaysOnTop == alwaysOnTop &&
        other.skipTaskbar == skipTaskbar &&
        other.transparent == transparent &&
        other.decorated == decorated &&
        other.ignoresMouseEvents == ignoresMouseEvents;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    id,
    entrypoint,
    size,
    minimumSize,
    title,
    position,
    center,
    resizable,
    alwaysOnTop,
    skipTaskbar,
    transparent,
    decorated,
    ignoresMouseEvents,
  ]);
}
