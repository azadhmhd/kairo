import 'package:kairo_event_bus/event_bus.dart';

import '../window/kairo_window_id.dart';

/// A window became available.
///
/// Published once the window exists and is registered, so a listener may act on
/// it immediately.
class KairoWindowOpened extends KairoEvent {
  /// Reports that the window [id] opened.
  const KairoWindowOpened(this.id);

  /// Which window opened.
  final KairoWindowId id;

  @override
  String toString() => 'KairoWindowOpened($id)';
}

/// A window went away.
///
/// Published after the window is unregistered, so a listener consulting the
/// registry sees the state the event describes.
///
/// Can arrive without Kairo asking: the user closing a window and the platform
/// taking one away both end up here.
class KairoWindowClosed extends KairoEvent {
  /// Reports that the window [id] closed.
  const KairoWindowClosed(this.id);

  /// Which window closed.
  final KairoWindowId id;

  @override
  String toString() => 'KairoWindowClosed($id)';
}
