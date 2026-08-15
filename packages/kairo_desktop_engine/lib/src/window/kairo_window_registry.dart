import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'kairo_window_controller.dart';
import 'kairo_window_id.dart';

/// Which windows currently exist, and how to drive each one.
///
/// Turns a [KairoWindowId] into something that can be acted upon, so a feature
/// that wants to show the character needs its identity, not its owner.
///
/// A window appears here only once it has actually been created, which makes
/// the registry the answer to "does this window exist yet?".
class KairoWindowRegistry {
  final Map<KairoWindowId, KairoWindowController> _controllers =
      <KairoWindowId, KairoWindowController>{};

  /// The windows that currently exist.
  Iterable<KairoWindowId> get registeredIds => _controllers.keys;

  /// Records that [id] now exists and is driven by [controller].
  ///
  /// Throws a [StateError] if [id] is already registered: two controllers for
  /// one window means one is stale, which is a bug worth failing on.
  void register(KairoWindowId id, KairoWindowController controller) {
    if (_controllers.containsKey(id)) {
      throw StateError(
        "A window is already registered for '$id'. "
        'Unregister it before registering another controller.',
      );
    }
    _controllers[id] = controller;
  }

  /// Forgets [id]. Unregistering a window that was never registered is not an
  /// error — the desired end state already holds.
  void unregister(KairoWindowId id) {
    _controllers.remove(id);
  }

  /// The controller for [id].
  ///
  /// Throws a [StateError] naming [id] when that window does not exist. Use
  /// [maybeController] where absence is an expected answer rather than a
  /// mistake.
  KairoWindowController controller(KairoWindowId id) {
    final KairoWindowController? controller = _controllers[id];
    if (controller == null) {
      throw StateError(
        "No window is registered for '$id'. "
        'It has either not been created yet or has already been closed.',
      );
    }
    return controller;
  }

  /// The controller for [id], or `null` when that window does not exist.
  KairoWindowController? maybeController(KairoWindowId id) => _controllers[id];
}

/// The application's [KairoWindowRegistry]. Mutable, so its lifetime is the
/// container's rather than the process's.
final Provider<KairoWindowRegistry> windowRegistryProvider =
    Provider<KairoWindowRegistry>((Ref ref) => KairoWindowRegistry());
