import 'package:flutter/foundation.dart';

import 'kairo_window_type.dart';

/// Identifies one window.
///
/// Windows are reached by identity rather than by reference, so a caller can
/// ask for the character's window without knowing whether it exists yet.
///
/// [type] says what the window is for; [instance] distinguishes two windows of
/// the same type, and is null for singletons such as the dashboard:
///
/// ```dart
/// const KairoWindowId(KairoWindowType.reminder, 'water');
/// const KairoWindowId(KairoWindowType.reminder, 'stand');
/// ```
///
/// Identity is by value, so an id rebuilt from its parts addresses the same
/// window and works as a map key.
@immutable
class KairoWindowId {
  /// Identifies the [instance] window of kind [type].
  const KairoWindowId(this.type, [this.instance]);

  /// The dashboard.
  static const KairoWindowId main = KairoWindowId(KairoWindowType.main);

  /// The character's stage.
  static const KairoWindowId character = KairoWindowId(
    KairoWindowType.character,
  );

  /// The settings window.
  static const KairoWindowId settings = KairoWindowId(KairoWindowType.settings);

  /// What this window is for.
  final KairoWindowType type;

  /// Which window of this [type], where more than one can exist.
  ///
  /// Null for types that only ever have a single window.
  final String? instance;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is KairoWindowId &&
        other.type == type &&
        other.instance == instance;
  }

  @override
  int get hashCode => Object.hash(type, instance);

  /// Renders as `main`, or `reminder#water` when there is an [instance]. The
  /// registry interpolates this into the errors it throws.
  @override
  String toString() => instance == null ? type.name : '${type.name}#$instance';
}
