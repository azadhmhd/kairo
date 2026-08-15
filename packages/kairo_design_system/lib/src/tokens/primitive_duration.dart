/// How long Kairo's motion takes.
///
/// Calm is the design language, so these are on the slow side of conventional:
/// nothing in Kairo should feel like it snapped into place.
abstract final class PrimitiveDuration {
  PrimitiveDuration._();

  /// A control acknowledging a click.
  static const Duration fast = Duration(milliseconds: 150);

  /// Something appearing or leaving.
  static const Duration normal = Duration(milliseconds: 250);

  /// A surface changing shape or size.
  static const Duration slow = Duration(milliseconds: 350);

  /// The character moving, and anything else meant to be watched.
  static const Duration slower = Duration(milliseconds: 500);
}
