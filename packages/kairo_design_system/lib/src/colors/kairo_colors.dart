import 'package:flutter/material.dart';

import '../tokens/primitive_colors.dart';

/// The semantic colour palette of Kairo.
///
/// Application code must use these names rather than [PrimitiveColors]
/// directly. A semantic name describes the *role* a colour plays, so the
/// underlying primitive can be retuned without touching call sites.
abstract final class KairoColors {
  KairoColors._();

  // Brand -------------------------------------------------------------------

  /// Soft leaf green. Primary actions and brand moments.
  static const Color primary = PrimitiveColors.green500;

  /// [primary] under a pointer.
  static const Color primaryHovered = PrimitiveColors.green600;

  /// [primary] while being pressed.
  static const Color primaryPressed = PrimitiveColors.green700;

  /// Tinted background for selected or highlighted regions.
  static const Color primarySubtle = PrimitiveColors.green100;

  /// Content drawn on top of [primary].
  static const Color onPrimary = PrimitiveColors.white;

  /// Soft blue. Supporting accents that should not compete with [primary].
  static const Color secondary = PrimitiveColors.blue500;

  /// Content drawn on top of [secondary].
  static const Color onSecondary = PrimitiveColors.white;

  /// Pastel green used for decoration, never for text.
  static const Color accent = PrimitiveColors.green300;

  // Surfaces ----------------------------------------------------------------

  /// Warm white application backdrop.
  static const Color background = PrimitiveColors.warmWhite;

  /// Cards, panels and floating windows.
  static const Color surface = PrimitiveColors.white;

  /// Recessed areas such as input fields and list hovers.
  static const Color surfaceSubtle = PrimitiveColors.neutral50;

  /// Content drawn on top of [background] and [surface].
  static const Color onSurface = PrimitiveColors.neutral800;

  // Lines -------------------------------------------------------------------

  /// Very light gray hairline. The default separator.
  static const Color border = PrimitiveColors.neutral200;

  /// Border for focused or emphasised elements.
  static const Color borderStrong = PrimitiveColors.neutral300;

  // Text --------------------------------------------------------------------

  /// Dark gray body and heading text. Never pure black.
  static const Color textPrimary = PrimitiveColors.neutral800;

  /// Supporting copy, captions and metadata.
  static const Color textSecondary = PrimitiveColors.neutral500;

  /// Placeholder and disabled text.
  static const Color textTertiary = PrimitiveColors.neutral400;

  // Feedback ----------------------------------------------------------------

  /// A goal met, a habit kept.
  static const Color success = PrimitiveColors.green500;

  /// Something needs attention but nothing is broken.
  static const Color warning = PrimitiveColors.yellow500;

  /// Something failed. Used sparingly; Kairo is never alarming.
  static const Color error = PrimitiveColors.red500;

  // Effects -----------------------------------------------------------------

  /// Base colour for shadows, always applied at a low opacity.
  static const Color shadow = PrimitiveColors.neutral900;
}
