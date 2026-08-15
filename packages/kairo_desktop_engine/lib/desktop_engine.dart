/// The Kairo desktop engine: control over the application's native windows.
library;

export 'src/engine/kairo_desktop_engine.dart';
export 'src/engine/kairo_window_event.dart';

export 'src/platform/kairo_isolate_channel.dart';
export 'src/platform/kairo_login_item.dart';
export 'src/platform/kairo_native_window_controller.dart';
// Exported for its data types — window levels and rectangles appear in the
// signatures above. The host API itself is reached through KairoDesktopEngine.
export 'src/platform/platform_bridge.g.dart';

export 'src/window/kairo_window_controller.dart';
export 'src/window/kairo_window_descriptor.dart';
export 'src/window/kairo_window_id.dart';
export 'src/window/kairo_window_registry.dart';
export 'src/window/kairo_window_service.dart';
export 'src/window/kairo_window_type.dart';
