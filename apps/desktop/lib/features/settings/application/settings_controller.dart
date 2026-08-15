import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo_desktop_engine/desktop_engine.dart';
import 'package:kairo_shared_models/shared_models.dart';
import 'package:kairo_storage/storage.dart';

import '../../character/application/character_presence.dart';

/// The user's settings, refreshed as they are changed.
final StreamProvider<UserSettings> settingsProvider =
    StreamProvider<UserSettings>(
  (Ref ref) => ref.watch(settingsRepositoryProvider).watch(),
);

/// Applies the choices the user makes on the settings screen.
///
/// Settings are not only rows: turning the character off has to take the window
/// away too. Keeping that here lets the settings screen stay a screen.
class SettingsController {
  /// Creates a controller writing through [_settings].
  const SettingsController({
    required SettingsRepository settings,
    required KairoDataRepository data,
    required KairoDesktopEngine desktop,
    required KairoLoginItem loginItem,
  })  : _settings = settings,
        _data = data,
        _desktop = desktop,
        _loginItem = loginItem;

  final SettingsRepository _settings;
  final KairoDataRepository _data;
  final KairoDesktopEngine _desktop;
  final KairoLoginItem _loginItem;

  /// Asks the system to start Kairo at login, and remembers the answer.
  ///
  /// System first, preference second, so a refusal leaves the stored setting
  /// matching reality. The exception reaches the caller, which is expected to
  /// tell the user why the switch slid back.
  Future<void> setLaunchAtLogin(UserSettings current, bool enabled) async {
    await _loginItem.setEnabled(enabled: enabled);
    await _settings.write(current.copyWith(launchAtLogin: enabled));
  }

  /// Sets the hours Kairo stays silent, or clears them when [window] is null.
  Future<void> setQuietHours(UserSettings current, DailyWindow? window) {
    return _settings.write(
      window == null
          ? current.withoutQuietHours()
          : current.copyWith(quietHours: window),
    );
  }

  /// Shows or hides the character, and remembers which. Takes effect now rather
  /// than at the next launch.
  Future<void> setCharacterEnabled(UserSettings current, bool enabled) async {
    await _settings.write(current.copyWith(characterEnabled: enabled));

    if (enabled) {
      if (_desktop.registry.maybeController(KairoWindowId.character) == null) {
        // Positioned as `bootstrap` positions it. The bare descriptor centres
        // the window, which would start the walk-on mid-screen.
        await _desktop.openWindow(
          KairoWindowDescriptor.characterWindow.at(
            characterPositionOn(await _desktop.activeDisplayBounds()),
          ),
        );
      }
    } else {
      await _desktop.closeWindow(KairoWindowId.character);
    }
  }

  /// Sets whether reminders make a sound.
  Future<void> setSoundEnabled(UserSettings current, bool enabled) {
    return _settings.write(current.copyWith(soundEnabled: enabled));
  }

  /// Writes everything Kairo knows to a file, and returns where it went.
  Future<File> exportData() => _data.exportToFile();

  /// Destroys every reminder, every occurrence and every preference.
  Future<void> deleteEverything() => _data.deleteEverything();
}

/// The application's [SettingsController].
final Provider<SettingsController> settingsControllerProvider =
    Provider<SettingsController>(
  (Ref ref) => SettingsController(
    settings: ref.watch(settingsRepositoryProvider),
    data: ref.watch(dataRepositoryProvider),
    desktop: ref.watch(desktopEngineProvider),
    loginItem: ref.watch(loginItemProvider),
  ),
);

/// Whether the system starts Kairo at login, as the system reports it.
///
/// Read from the system rather than from the stored setting, which can be out
/// of date: login items can be removed in System Settings while Kairo is not
/// even running.
final FutureProvider<bool> launchesAtLoginProvider = FutureProvider<bool>(
  (Ref ref) => ref.watch(loginItemProvider).isEnabled(),
);
