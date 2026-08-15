import 'package:flutter/material.dart';

import '../colors/kairo_colors.dart';
import '../radius/kairo_radius.dart';
import '../spacing/kairo_spacing.dart';
import '../tokens/primitive_icon_size.dart';
import '../typography/kairo_typography.dart';

/// Builds the [ThemeData] that every Kairo surface inherits.
///
/// This is the only place Material defaults are overridden. Widgets read
/// styling from `Theme.of(context)`, or from the semantic token classes when
/// they need a value Material has no slot for.
abstract final class KairoTheme {
  KairoTheme._();

  /// Border width for hairlines and input outlines, in logical pixels.
  static const double _hairline = 1;

  /// Kairo ships light-only. The palette is defined for a warm, bright
  /// workspace and a dark variant would be a separate design exercise.
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: _colorScheme,
    scaffoldBackgroundColor: KairoColors.background,
    canvasColor: KairoColors.background,
    textTheme: KairoTypography.textTheme,
    // Desktop pointers are precise, so controls can be tighter than touch.
    visualDensity: VisualDensity.comfortable,
    iconTheme: const IconThemeData(
      color: KairoColors.textSecondary,
      size: PrimitiveIconSize.lg,
    ),
    dividerTheme: const DividerThemeData(
      color: KairoColors.border,
      thickness: _hairline,
      space: _hairline,
    ),
    cardTheme: CardThemeData(
      color: KairoColors.surface,
      surfaceTintColor: Colors.transparent,
      // Shadows come from KairoShadows, painted by the widget itself, so the
      // Material elevation shadow is switched off here.
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: KairoRadius.cardBorderRadius,
        side: BorderSide(color: KairoColors.border, width: _hairline),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: KairoColors.primary,
        foregroundColor: KairoColors.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: KairoSpacing.lg,
          vertical: KairoSpacing.sm,
        ),
        textStyle: KairoTypography.textTheme.labelLarge,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(KairoRadius.md)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: KairoColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: KairoSpacing.md,
          vertical: KairoSpacing.xs,
        ),
        textStyle: KairoTypography.textTheme.labelLarge,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(KairoRadius.sm)),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: KairoColors.surfaceSubtle,
      hintStyle: KairoTypography.textTheme.bodyMedium?.copyWith(
        color: KairoColors.textTertiary,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: KairoSpacing.md,
        vertical: KairoSpacing.sm,
      ),
      border: _inputBorder(KairoColors.border),
      enabledBorder: _inputBorder(KairoColors.border),
      focusedBorder: _inputBorder(KairoColors.primary),
      errorBorder: _inputBorder(KairoColors.error),
      focusedErrorBorder: _inputBorder(KairoColors.error),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: KairoColors.background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: KairoColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),
  );

  static const ColorScheme _colorScheme = ColorScheme.light(
    primary: KairoColors.primary,
    onPrimary: KairoColors.onPrimary,
    primaryContainer: KairoColors.primarySubtle,
    onPrimaryContainer: KairoColors.textPrimary,
    secondary: KairoColors.secondary,
    onSecondary: KairoColors.onSecondary,
    tertiary: KairoColors.accent,
    onTertiary: KairoColors.textPrimary,
    surface: KairoColors.surface,
    onSurface: KairoColors.onSurface,
    surfaceContainerLowest: KairoColors.surface,
    surfaceContainerLow: KairoColors.background,
    surfaceContainer: KairoColors.surfaceSubtle,
    onSurfaceVariant: KairoColors.textSecondary,
    outline: KairoColors.border,
    outlineVariant: KairoColors.borderStrong,
    error: KairoColors.error,
    onError: KairoColors.onPrimary,
    shadow: KairoColors.shadow,
  );

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(KairoRadius.sm)),
    borderSide: BorderSide(color: color, width: _hairline),
  );
}
