import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'platform_bridge.g.dart';

/// Kairo's registration as something the system starts at login.
///
/// The system owns this: the user can add or remove Kairo from their login
/// items with the application closed. Everything here asks the system rather
/// than remembering, so the settings screen shows what is actually true.
class KairoLoginItem {
  /// Creates a login item backed by the platform bridge.
  KairoLoginItem({KairoNativeSystemApi? system})
    : _system = system ?? KairoNativeSystemApi();

  final KairoNativeSystemApi _system;

  /// Whether the system currently starts Kairo at login.
  Future<bool> isEnabled() => _system.launchesAtLogin();

  /// Asks the system to start Kairo at login, or to stop.
  ///
  /// Throws if the system refuses — macOS below 13, or the user denying it. The
  /// caller must tell the user rather than record a preference that did not
  /// take effect.
  Future<void> setEnabled({required bool enabled}) =>
      _system.setLaunchAtLogin(enabled);
}

/// The application's [KairoLoginItem].
final Provider<KairoLoginItem> loginItemProvider = Provider<KairoLoginItem>(
  (Ref ref) => KairoLoginItem(),
);
