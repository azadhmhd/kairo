import 'package:flutter/widgets.dart';

import '../colors/kairo_colors.dart';
import '../tokens/primitive_opacity.dart';

/// The elevation scale of Kairo.
///
/// Shadows are wide, soft and nearly colourless. They suggest that a surface
/// is floating without drawing a visible edge around it.
abstract final class KairoShadows {
  KairoShadows._();

  /// Vertical offsets, in logical pixels, paired with the blur radii below.
  static const double _softOffsetY = 2;
  static const double _cardOffsetY = 6;
  static const double _floatingOffsetY = 16;

  /// Blur radii, in logical pixels. Large values keep the falloff gentle.
  static const double _softBlur = 12;
  static const double _cardBlur = 24;
  static const double _floatingBlur = 48;

  /// A resting surface that sits just above the background.
  static final List<BoxShadow> soft = <BoxShadow>[
    BoxShadow(
      color: KairoColors.shadow.withValues(alpha: PrimitiveOpacity.faint),
      offset: const Offset(0, _softOffsetY),
      blurRadius: _softBlur,
    ),
  ];

  /// A card or list tile lifted off the background.
  static final List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: KairoColors.shadow.withValues(alpha: PrimitiveOpacity.faint),
      offset: const Offset(0, _softOffsetY),
      blurRadius: _softBlur,
    ),
    BoxShadow(
      color: KairoColors.shadow.withValues(alpha: PrimitiveOpacity.subtle),
      offset: const Offset(0, _cardOffsetY),
      blurRadius: _cardBlur,
    ),
  ];

  /// A panel, popover or companion window floating over the application.
  static final List<BoxShadow> floating = <BoxShadow>[
    BoxShadow(
      color: KairoColors.shadow.withValues(alpha: PrimitiveOpacity.subtle),
      offset: const Offset(0, _cardOffsetY),
      blurRadius: _cardBlur,
    ),
    BoxShadow(
      color: KairoColors.shadow.withValues(alpha: PrimitiveOpacity.soft),
      offset: const Offset(0, _floatingOffsetY),
      blurRadius: _floatingBlur,
    ),
  ];
}
