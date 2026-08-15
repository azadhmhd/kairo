/// Raw icon dimensions in logical pixels.
///
/// Primitives carry no meaning on their own. Semantic layers such as
/// [KairoTheme] decide where each value is appropriate.
abstract final class PrimitiveIconSize {
  PrimitiveIconSize._();

  static const double xs = 12;
  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 32;
}
