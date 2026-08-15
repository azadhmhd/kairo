import 'package:flutter/material.dart';

import '../colors/kairo_colors.dart';

/// The type scale of Kairo.
///
/// No font is bundled: leaving `fontFamily` unset resolves the platform UI font
/// — SF Pro on macOS, Segoe UI on Windows — which is what makes the application
/// feel native. Weights stay at or below [FontWeight.w600].
abstract final class KairoTypography {
  KairoTypography._();

  /// Multiplied against font size to produce comfortable line height.
  static const double _tightLineHeight = 1.2;
  static const double _normalLineHeight = 1.4;
  static const double _relaxedLineHeight = 1.5;

  /// The complete type scale, applied by `KairoTheme`.
  static const TextTheme textTheme = TextTheme(
    displaySmall: TextStyle(
      fontSize: 34,
      height: _tightLineHeight,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.6,
      color: KairoColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      height: _tightLineHeight,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.4,
      color: KairoColors.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontSize: 22,
      height: _normalLineHeight,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: KairoColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      height: _normalLineHeight,
      fontWeight: FontWeight.w600,
      color: KairoColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      height: _normalLineHeight,
      fontWeight: FontWeight.w500,
      color: KairoColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: _relaxedLineHeight,
      fontWeight: FontWeight.w400,
      color: KairoColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: _relaxedLineHeight,
      fontWeight: FontWeight.w400,
      color: KairoColors.textPrimary,
    ),
    bodySmall: TextStyle(
      fontSize: 13,
      height: _relaxedLineHeight,
      fontWeight: FontWeight.w400,
      color: KairoColors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      height: _normalLineHeight,
      fontWeight: FontWeight.w500,
      color: KairoColors.textPrimary,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      height: _normalLineHeight,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      color: KairoColors.textSecondary,
    ),
  );
}
