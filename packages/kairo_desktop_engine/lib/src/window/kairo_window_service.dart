import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'kairo_window_controller.dart';
import 'kairo_window_descriptor.dart';

/// Drives Kairo's main window. The only code that calls `window_manager`.
///
/// Flutter's own first-party windowing API is still experimental and off the
/// stable channel. When it lands, this is the only file that has to change.
class KairoWindowService implements KairoWindowController {
  /// Creates a service that drives the platform's main window.
  const KairoWindowService();

  /// Shapes the window described by [descriptor] and reveals it. It stays
  /// hidden until sized and positioned, so it never visibly resizes at launch.
  Future<void> applyStartupDescriptor(KairoWindowDescriptor descriptor) async {
    await windowManager.ensureInitialized();

    final WindowOptions options = WindowOptions(
      size: descriptor.size,
      minimumSize: descriptor.minimumSize,
      center: descriptor.center,
      title: descriptor.title,
      alwaysOnTop: descriptor.alwaysOnTop,
      skipTaskbar: descriptor.skipTaskbar,
    );

    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.setResizable(descriptor.resizable);
      await windowManager.show();
      await windowManager.focus();
    });
  }

  @override
  Future<void> show() => windowManager.show();

  @override
  Future<void> hide() => windowManager.hide();

  @override
  Future<void> focus() => windowManager.focus();

  @override
  Future<void> close() => windowManager.close();

  @override
  Future<void> move(Offset position) => windowManager.setPosition(position);

  @override
  Future<void> resize(Size size) => windowManager.setSize(size);

  @override
  Future<Rect> bounds() => windowManager.getBounds();

  @override
  Future<bool> isVisible() => windowManager.isVisible();
}

/// The application's [KairoWindowService].
final Provider<KairoWindowService> windowServiceProvider =
    Provider<KairoWindowService>((Ref ref) => const KairoWindowService());
