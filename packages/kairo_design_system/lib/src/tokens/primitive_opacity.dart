/// Raw opacity values.
///
/// Primitives carry no meaning on their own. Semantic layers such as
/// [KairoShadows] decide where each value is appropriate.
abstract final class PrimitiveOpacity {
  PrimitiveOpacity._();

  static const double none = 0;
  static const double faint = 0.04;
  static const double subtle = 0.08;
  static const double soft = 0.12;
  static const double medium = 0.24;
  static const double disabled = 0.38;
  static const double strong = 0.64;
  static const double full = 1;
}
