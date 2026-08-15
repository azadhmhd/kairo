import 'package:flutter/material.dart';

import '../colors/kairo_colors.dart';
import '../radius/kairo_radius.dart';
import '../shadows/kairo_shadows.dart';
import '../spacing/kairo_spacing.dart';

/// A raised surface holding related content.
///
/// Carries its own shadow rather than Material's elevation, which is too hard
/// for Kairo's palette. `KairoTheme` switches Material's off; this puts the
/// right one back.
class KairoCard extends StatelessWidget {
  /// Creates a card around [child].
  const KairoCard({
    required this.child,
    this.padding = const EdgeInsets.all(KairoSpacing.lg),
    this.onTap,
    super.key,
  });

  /// The content of the card.
  final Widget child;

  /// Space between the card's edge and its content.
  final EdgeInsetsGeometry padding;

  /// Called when the card is clicked, or null if it is not interactive.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget surface = Padding(padding: padding, child: child);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: KairoColors.surface,
        borderRadius: KairoRadius.cardBorderRadius,
        border: Border.all(color: KairoColors.border),
        boxShadow: KairoShadows.card,
      ),
      // The Material is here whether or not the card is tappable. Anything that
      // draws ink — a ListTile, a Switch, a checkbox — paints onto the nearest
      // Material ancestor, and without one inside this box it would paint onto
      // whatever is behind the card and be hidden by the background above. It
      // is transparent, so it changes nothing about how the card looks.
      child: Material(
        type: MaterialType.transparency,
        child: onTap == null
            ? surface
            : InkWell(
                onTap: onTap,
                borderRadius: KairoRadius.cardBorderRadius,
                child: surface,
              ),
      ),
    );
  }
}
