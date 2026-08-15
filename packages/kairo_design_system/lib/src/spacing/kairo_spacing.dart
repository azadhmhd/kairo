import '../tokens/primitive_spacing.dart';

/// The spacing scale of Kairo, in logical pixels.
///
/// Kairo favours breathing space: when two steps look equally correct,
/// choose the larger one.
abstract final class KairoSpacing {
  KairoSpacing._();

  /// Hairline gaps, e.g. between an icon and its label.
  static const double xxs = PrimitiveSpacing.xxs;

  /// Tight gaps inside a single control.
  static const double xs = PrimitiveSpacing.xs;

  /// Gaps between closely related elements.
  static const double sm = PrimitiveSpacing.sm;

  /// The default gap. Padding inside compact cards.
  static const double md = PrimitiveSpacing.md;

  /// Padding inside cards and panels.
  static const double lg = PrimitiveSpacing.lg;

  /// Gaps between sections of a screen.
  static const double xl = PrimitiveSpacing.xl;

  /// Padding around the content of a window.
  static const double xxl = PrimitiveSpacing.xxl;

  /// Generous separation between major regions.
  static const double xxxl = PrimitiveSpacing.xxxl;

  /// Reserved for empty states and hero moments.
  static const double huge = PrimitiveSpacing.huge;
}
