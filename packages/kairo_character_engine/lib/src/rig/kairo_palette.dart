import 'package:flutter/painting.dart';

/// The colours the character is drawn from, transcribed from the character
/// sheet.
///
/// Deliberately separate from `kairo_design_system`: skin, hair and denim are
/// art rather than interface tokens, and a theme change must never repaint the
/// character. Only the hoodie colour is a caller's to choose.
abstract final class KairoPalette {
  KairoPalette._();

  /// The hoodie, the shoes, and the character's primary read.
  static const Color forest = Color(0xFF3E7C4F);

  /// The hood lining, seams and shading under [forest].
  static const Color forestDark = Color(0xFF2F5E3C);

  /// Drawstrings, sparkles and props.
  static const Color mint = Color(0xFFA9D9BB);

  /// The tee shirt and the shoe soles.
  static const Color cream = Color(0xFFF8F5EF);

  /// Outlines where a shape is nearly white and would otherwise vanish.
  static const Color gray = Color(0xFFC8CCC8);

  /// The ground shadow and the laptop shell.
  static const Color coal = Color(0xFF2C302E);

  /// Face, hands and ears.
  static const Color skin = Color(0xFFF9DFC4);

  /// The shaded edge of [skin]: the neck, the nose and the eye crease.
  static const Color skinShaded = Color(0xFFEAC19E);

  /// Hair.
  static const Color hair = Color(0xFF28201B);

  /// The lit strands across the top of the hair.
  static const Color hairHighlight = Color(0xFF4A3A2E);

  /// The inside of an open mouth.
  static const Color mouth = Color(0xFF8A4B3C);

  /// The tongue, visible only when laughing.
  static const Color tongue = Color(0xFFE58A74);

  /// Blush.
  static const Color cheek = Color(0xFFF2AE93);

  /// The stroke every facial line is drawn with.
  static const Color line = Color(0xFF5A4638);

  /// Denim.
  static const Color denim = Color(0xFF23262A);

  /// Denim on the far leg in the side view, where it reads as shadowed.
  static const Color denimShaded = Color(0xFF363B3E);

  /// Tears and sweat drops.
  static const Color water = Color(0xFF9CC7E8);

  /// A lit laptop screen.
  static const Color screen = Color(0xFF3D4A44);

  /// The tee shirt's own shadow under the collar.
  static const Color creamShaded = Color(0xFFE6E0D4);

  /// The pupil, which is darker than the darkest iris stop.
  static const Color pupil = Color(0xFF161D18);

  /// The three stops of the iris gradient, from the lit centre outwards.
  static const List<Color> iris = <Color>[
    Color(0xFF6B9A72),
    Color(0xFF3E6B4A),
    Color(0xFF243A2C),
  ];

  /// Renders [colour] as the `#rrggbb` string an SVG attribute expects.
  ///
  /// Alpha is dropped: the rig expresses transparency with `opacity`
  /// attributes, never with an alpha channel in a fill.
  static String hex(Color colour) =>
      '#${(colour.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  /// The shaded companion to a hoodie [colour] — hood lining, seams, cuffs.
  ///
  /// The character sheet mixes 28% black into the hoodie colour in the OKLab
  /// space. This mixes in sRGB instead, which is a shade darker at the same
  /// ratio and indistinguishable at the sizes the character is drawn.
  //
  // ponytail: sRGB lerp, move to an OKLab mix only if the seams read wrong
  // beside the character sheet.
  static Color shade(Color colour) =>
      Color.lerp(colour, const Color(0xFF000000), 0.28)!;
}
