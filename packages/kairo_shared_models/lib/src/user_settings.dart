import 'package:flutter/foundation.dart';

import 'ai_settings.dart';
import 'daily_window.dart';

/// How the user has asked Kairo to behave.
///
/// Every field is a preference the user set. Nothing is derived or inferred,
/// and nothing leaves the machine.
@immutable
class UserSettings {
  /// Creates settings from explicit values.
  const UserSettings({
    this.quietHours,
    this.launchAtLogin = false,
    this.characterEnabled = true,
    this.soundEnabled = true,
    this.ai = AiSettings.defaults,
  });

  /// What a new installation starts with. Launch at login is off: Kairo does
  /// not add itself to a user's startup items uninvited.
  static const UserSettings defaults = UserSettings();

  /// Hours in which Kairo shows nothing at all.
  ///
  /// `null` means the user has not asked for quiet hours. This silences every
  /// reminder regardless of its own active hours.
  final DailyWindow? quietHours;

  /// Whether Kairo starts when the user logs in.
  final bool launchAtLogin;

  /// Whether the character is shown on the desktop. Turning it off leaves the
  /// reminders working; they arrive without the companion.
  final bool characterEnabled;

  /// Whether reminders make a sound.
  final bool soundEnabled;

  /// Where coaching messages are written, if the user wants any.
  final AiSettings ai;

  /// Whether Kairo should stay silent at [time].
  bool isQuietAt(DateTime time) => quietHours?.contains(time) ?? false;

  /// Returns a copy of these settings with the given fields replaced.
  ///
  /// [quietHours] cannot be cleared this way; use [withoutQuietHours].
  UserSettings copyWith({
    DailyWindow? quietHours,
    bool? launchAtLogin,
    bool? characterEnabled,
    bool? soundEnabled,
    AiSettings? ai,
  }) {
    return UserSettings(
      quietHours: quietHours ?? this.quietHours,
      launchAtLogin: launchAtLogin ?? this.launchAtLogin,
      characterEnabled: characterEnabled ?? this.characterEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      ai: ai ?? this.ai,
    );
  }

  /// Returns a copy of these settings with quiet hours turned off.
  UserSettings withoutQuietHours() {
    return UserSettings(
      launchAtLogin: launchAtLogin,
      characterEnabled: characterEnabled,
      soundEnabled: soundEnabled,
      ai: ai,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UserSettings &&
      other.quietHours == quietHours &&
      other.launchAtLogin == launchAtLogin &&
      other.characterEnabled == characterEnabled &&
      other.soundEnabled == soundEnabled &&
      other.ai == ai;

  @override
  int get hashCode =>
      Object.hash(quietHours, launchAtLogin, characterEnabled, soundEnabled, ai);

  @override
  String toString() => 'UserSettings(quiet: ${quietHours ?? 'none'}, '
      'launchAtLogin: $launchAtLogin, character: $characterEnabled, '
      'sound: $soundEnabled, ai: $ai)';
}
