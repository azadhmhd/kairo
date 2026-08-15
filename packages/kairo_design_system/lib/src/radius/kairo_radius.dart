import 'package:flutter/widgets.dart';

import '../tokens/primitive_radius.dart';

/// The corner radius scale of Kairo, in logical pixels.
///
/// Kairo is a rounded product. Square corners are reserved for full-bleed
/// surfaces that reach the edge of the window.
abstract final class KairoRadius {
  KairoRadius._();

  /// Full-bleed surfaces only.
  static const double none = PrimitiveRadius.none;

  /// Badges and other very small chrome.
  static const double xs = PrimitiveRadius.xs;

  /// Inputs, chips and compact buttons.
  static const double sm = PrimitiveRadius.sm;

  /// The default. Buttons and small cards.
  static const double md = PrimitiveRadius.md;

  /// Cards and list tiles.
  static const double lg = PrimitiveRadius.lg;

  /// Panels and dialogs.
  static const double xl = PrimitiveRadius.xl;

  /// Floating windows and the character stage.
  static const double xxl = PrimitiveRadius.xxl;

  /// Fully rounded ends, e.g. pill buttons and progress tracks.
  static const double pill = PrimitiveRadius.pill;

  /// Ready-made [BorderRadius] for a card surface.
  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(lg),
  );

  /// Ready-made [BorderRadius] for a panel or dialog.
  static const BorderRadius panelBorderRadius = BorderRadius.all(
    Radius.circular(xl),
  );

  /// Ready-made [BorderRadius] for a pill-shaped control.
  static const BorderRadius pillBorderRadius = BorderRadius.all(
    Radius.circular(pill),
  );
}
