import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'kairo_palette.dart';
import 'kairo_pose.dart';

/// The drawings of the character's body, in every view.
///
/// Every string is a fragment of SVG in the rig's own 200×236 coordinate space.
/// Nothing here knows what the character is doing: a leg is the same drawing
/// standing still or mid-stride, and only the angle changes.
///
/// One instance covers one hoodie colour, because the colour is woven into the
/// strings.
class KairoBodyParts {
  /// Draws the body with a hoodie of the given colour.
  KairoBodyParts(this.hoodie)
    : _hood = KairoPalette.hex(hoodie),
      _hoodDark = KairoPalette.hex(KairoPalette.shade(hoodie));

  /// The hoodie's colour. Also the shoes', and the cup's rim.
  final Color hoodie;

  final String _hood;
  final String _hoodDark;

  static final String _skin = KairoPalette.hex(KairoPalette.skin);
  static final String _skinShaded = KairoPalette.hex(KairoPalette.skinShaded);
  static final String _hair = KairoPalette.hex(KairoPalette.hair);
  static final String _hairHighlight = KairoPalette.hex(
    KairoPalette.hairHighlight,
  );
  static final String _denim = KairoPalette.hex(KairoPalette.denim);
  static final String _cream = KairoPalette.hex(KairoPalette.cream);
  static final String _gray = KairoPalette.hex(KairoPalette.gray);
  static final String _coal = KairoPalette.hex(KairoPalette.coal);
  static final String _mint = KairoPalette.hex(KairoPalette.mint);
  static final String _forestDark = KairoPalette.hex(KairoPalette.forestDark);

  /// The soft ellipse on the ground beneath the character.
  static String get groundShadow =>
      '<ellipse cx="100" cy="222" rx="38" ry="6" fill="$_coal" opacity=".1"/>';

  // ---------------------------------------------------------------- front --

  /// The left leg, seen from the front, with its shoe.
  String get frontLegLeft =>
      '<path d="M83 168 L97 168 L95 200 L86 200 Z" fill="$_denim"/>'
      '<path d="M86 185 Q90 187 94 185" stroke="#000000" stroke-width="1.3" '
      'opacity=".3" fill="none"/>'
      '${_shoe(90, toesLeft: true)}';

  /// The right leg, seen from the front, with its shoe.
  String get frontLegRight =>
      '<path d="M103 168 L117 168 L114 200 L105 200 Z" fill="$_denim"/>'
      '<path d="M106 185 Q110 187 114 185" stroke="#000000" '
      'stroke-width="1.3" opacity=".3" fill="none"/>'
      '${_shoe(110, toesLeft: false)}';

  /// The neck, hood, hoodie, tee shirt, seams and pockets.
  String get frontTorso =>
      '<path d="M94 110 L106 110 L106 124 L94 124 Z" fill="$_skinShaded"/>'
      '<path d="M72 126 C69 118 84 112 100 112 C116 112 131 118 128 126 '
      'C126 131 74 131 72 126 Z" fill="$_hoodDark"/>'
      '<path d="M75 121 C70 148 71 166 76 176 L124 176 C129 166 130 148 '
      '125 121 C112 114 88 114 75 121 Z" fill="$_hood"/>'
      '<path d="M92 118 L88 176 L112 176 L108 118 Q100 115 92 118 Z" '
      'fill="$_cream"/>'
      '<path d="M92 118 Q100 124 108 118 L108 123 Q100 128 92 123 Z" '
      'fill="${KairoPalette.hex(KairoPalette.creamShaded)}"/>'
      '<path d="M92 118 L87 176 M108 118 L113 176" stroke="$_hoodDark" '
      'stroke-width="3" fill="none"/>'
      '<path d="M92 117 L98 125 L91 129 Q87 122 92 117 Z M108 117 L102 125 '
      'L109 129 Q113 122 108 117 Z" fill="$_hoodDark"/>'
      '<path d="M95 122 L95 132 M105 122 L105 132" stroke="$_mint" '
      'stroke-width="2.4" stroke-linecap="round"/>'
      '<path d="M79 140 Q82 145 80 152 M121 140 Q118 145 120 152 M83 168 '
      'Q88 170 92 169" stroke="$_hoodDark" stroke-width="1.5" opacity=".5" '
      'fill="none"/>'
      '<path d="M77 171 L123 171" stroke="$_hoodDark" stroke-width="2.2" '
      'opacity=".55"/>'
      '<path d="M80 158 L88 158 L86 173 L79 173 Z M120 158 L112 158 L114 173 '
      'L121 173 Z" fill="$_hoodDark" opacity=".35"/>';

  /// The left arm, seen from the front.
  String get frontArmLeft =>
      '<path d="M75 130 C68 142 66 155 67 165" stroke="$_hood" '
      'stroke-width="13" stroke-linecap="round" fill="none"/>'
      '<path d="M63.5 158 L71.5 160" stroke="$_hoodDark" stroke-width="4.5" '
      'stroke-linecap="round"/>'
      '<circle cx="67" cy="169" r="6" fill="$_skin"/>';

  /// The right arm, seen from the front, holding [prop] if it is a held one.
  ///
  /// A bottle, a cup and a raised thumb belong to the hand, so they are drawn
  /// into the arm and turn with it. A book and a laptop are held in both hands
  /// and stay level; those are drawn by [heldInBothHands] instead.
  String frontArmRight(KairoProp? prop) =>
      '<path d="M125 130 C132 142 134 155 133 165" stroke="$_hood" '
      'stroke-width="13" stroke-linecap="round" fill="none"/>'
      '<path d="M128.5 160 L136.5 158" stroke="$_hoodDark" '
      'stroke-width="4.5" stroke-linecap="round"/>'
      '<circle cx="133" cy="169" r="6" fill="$_skin"/>'
      '${_heldInOneHand(prop)}';

  /// The head, without the face: hair, ears and the bare face shape.
  ///
  /// In the three-quarter view the features slide across the face rather than
  /// being redrawn, so [threeQuarter] nudges the ears and the face shape the
  /// small amount the turn calls for.
  String frontHead({required bool threeQuarter}) {
    final double shift = threeQuarter ? -7 : 0;
    return '<path d="M100 28 C60 28 43 55 45 87 C46 104 54 116 65 121 L135 121 '
        'C146 116 154 104 155 87 C157 55 140 28 100 28 Z" fill="$_hair"/>'
        '<circle cx="${54 + shift * 0.4}" cy="94" r="6.5" fill="$_skin"/>'
        '<circle cx="${146 + shift * 0.4}" cy="94" r="6.5" fill="$_skin"/>'
        '<ellipse cx="${100 + shift * 0.3}" cy="88" rx="46" ry="42" '
        'fill="$_skin"/>'
        '<path d="M55 84 C50 46 72 28 100 28 C128 28 150 46 145 84 Q141 71 '
        '136 82 Q132 62 126 77 Q120 58 113 73 Q107 56 100 71 Q93 56 87 73 '
        'Q80 58 74 77 Q68 62 64 82 Q59 71 55 84 Z" fill="$_hair"/>'
        '<path d="M62 78 Q76 66 100 66 Q124 66 138 78" stroke="$_skinShaded" '
        'stroke-width="4" opacity=".28" fill="none"/>'
        '<path d="M55 82 Q48 96 52 111 Q58 113 61 106 Q56 94 58 84 Z M145 82 '
        'Q152 96 148 111 Q142 113 139 106 Q144 94 142 84 Z" fill="$_hair"/>'
        '<path d="M97 30 C94 20 104 15 109 21 C104 20 99 25 101 30 Z" '
        'fill="$_hair"/>'
        '<path d="M70 46 Q83 35 100 34 M114 36 Q127 40 135 50" '
        'stroke="$_hairHighlight" stroke-width="3.2" fill="none" '
        'stroke-linecap="round" opacity=".75"/>';
  }

  // ----------------------------------------------------------------- side --

  /// The far leg, seen from the side.
  String get sideLegFar =>
      '<path d="M93 168 L107 168 L105 200 L96 200 Z" '
      'fill="${KairoPalette.hex(KairoPalette.denimShaded)}"/>'
      '<path d="M92 200 L92 212 L118 212 L118 206 Q106 202 108 200 Z" '
      'fill="$_hoodDark"/>'
      '<rect x="91" y="211" width="28" height="6" rx="3" fill="$_gray"/>';

  /// The near leg, seen from the side.
  String get sideLegNear =>
      '<path d="M99 168 L113 168 L111 200 L102 200 Z" fill="$_denim"/>'
      '<path d="M98 200 L98 212 L124 212 L124 206 Q112 202 114 200 Z" '
      'fill="$_hood"/>'
      '<rect x="97" y="211" width="28" height="6" rx="3" fill="$_cream" '
      'stroke="$_gray" stroke-width="1"/>';

  /// The far arm, seen from the side.
  String get sideArmFar =>
      '<path d="M104 132 C100 144 99 156 100 165" stroke="$_hoodDark" '
      'stroke-width="13" stroke-linecap="round" fill="none"/>'
      '<circle cx="100" cy="169" r="6" fill="$_skinShaded"/>';

  /// The near arm, seen from the side.
  String get sideArmNear =>
      '<path d="M108 132 C112 144 113 156 112 165" stroke="$_hood" '
      'stroke-width="13" stroke-linecap="round" fill="none"/>'
      '<circle cx="112" cy="169" r="6" fill="$_skin"/>';

  /// The torso, seen from the side.
  String get sideTorso =>
      '<path d="M88 122 C82 148 83 166 88 176 L120 176 C125 166 126 148 '
      '122 121 C112 115 96 115 88 122 Z" fill="$_hood"/>'
      '<path d="M86 124 C78 128 76 140 80 150 C84 142 85 132 88 126 Z" '
      'fill="$_hoodDark"/>'
      '<path d="M90 158 L114 158 L112 173 L90 173 Z" fill="$_hoodDark" '
      'opacity=".3"/>';

  /// The head, without the face, seen from the side.
  String get sideHead =>
      '<ellipse cx="104" cy="88" rx="45" ry="42" fill="$_skin"/>'
      '<path d="M104 28 C64 28 46 55 48 88 C49 106 58 118 70 122 C64 108 '
      '62 96 64 84 C70 88 76 86 80 76 C90 82 118 80 130 60 C138 52 146 60 '
      '148 74 C150 50 136 28 104 28 Z" fill="$_hair"/>'
      '<path d="M130 60 C140 56 148 64 148 78 C146 90 142 96 138 98 C140 86 '
      '138 72 130 60 Z" fill="$_hair"/>'
      '<circle cx="104" cy="94" r="6.5" fill="$_skin"/>'
      '<path d="M101 32 C98 22 108 17 113 23 C108 22 103 27 105 32 Z" '
      'fill="$_hair"/>';

  // ----------------------------------------------------------------- back --

  /// The left leg, seen from behind.
  String get backLegLeft =>
      '<path d="M83 168 L97 168 L95 200 L86 200 Z" fill="$_denim"/>'
      '<rect x="79" y="200" width="22" height="11" rx="4" fill="$_hood"/>'
      '<rect x="78" y="210" width="24" height="6" rx="3" fill="$_cream" '
      'stroke="$_gray" stroke-width="1"/>';

  /// The right leg, seen from behind.
  String get backLegRight =>
      '<path d="M103 168 L117 168 L114 200 L105 200 Z" fill="$_denim"/>'
      '<rect x="99" y="200" width="22" height="11" rx="4" fill="$_hood"/>'
      '<rect x="98" y="210" width="24" height="6" rx="3" fill="$_cream" '
      'stroke="$_gray" stroke-width="1"/>';

  /// The torso and the hood lying against it, seen from behind.
  String get backTorso =>
      '<path d="M75 121 C70 148 71 166 76 176 L124 176 C129 166 130 148 '
      '125 121 C112 114 88 114 75 121 Z" fill="$_hood"/>'
      '<path d="M78 122 C84 112 116 112 122 122 C124 136 118 148 100 148 '
      'C82 148 76 136 78 122 Z" fill="$_hoodDark"/>';

  /// The left arm, seen from behind.
  String get backArmLeft =>
      '<path d="M75 130 C68 142 66 155 67 165" stroke="$_hood" '
      'stroke-width="13" stroke-linecap="round" fill="none"/>'
      '<circle cx="67" cy="169" r="6" fill="$_skin"/>';

  /// The right arm, seen from behind.
  String get backArmRight =>
      '<path d="M125 130 C132 142 134 155 133 165" stroke="$_hood" '
      'stroke-width="13" stroke-linecap="round" fill="none"/>'
      '<circle cx="133" cy="169" r="6" fill="$_skin"/>';

  /// The back of the head, and the crown of hair.
  String get backHead =>
      '<path d="M100 28 C60 28 43 55 45 88 C46 108 58 122 74 126 L126 126 '
      'C142 122 154 108 155 88 C157 55 140 28 100 28 Z" fill="$_hair"/>'
      '<path d="M100 40 C90 44 84 52 84 60 C90 54 98 50 108 50 C116 50 '
      '122 54 126 60 C124 50 114 42 100 40 Z" fill="$_hairHighlight" '
      'opacity=".45"/>'
      '<circle cx="53" cy="94" r="5" fill="$_skin"/>'
      '<circle cx="147" cy="94" r="5" fill="$_skin"/>';

  // ----------------------------------------------------------------- props --

  /// A prop held level in both hands, or an empty string for any other prop.
  String heldInBothHands(KairoProp? prop) => switch (prop) {
    KairoProp.book =>
      '<path d="M84 150 L100 156 L116 150 L116 172 L100 178 L84 172 Z" '
          'fill="$_cream" stroke="$_gray" stroke-width="1.5"/>'
          '<path d="M100 156 L100 178" stroke="$_gray" stroke-width="1.5"/>',
    KairoProp.laptop =>
      '<path d="M82 148 L118 148 L118 168 L82 168 Z" fill="$_coal"/>'
          '<path d="M84 150 L116 150 L116 165 L84 165 Z" '
          'fill="${KairoPalette.hex(KairoPalette.screen)}"/>'
          '<path d="M78 168 L122 168 L124 174 L76 174 Z" fill="$_gray"/>',
    _ => '',
  };

  String _heldInOneHand(KairoProp? prop) => switch (prop) {
    KairoProp.bottle =>
      '<rect x="128" y="146" width="10" height="24" rx="4" fill="$_mint" '
          'stroke="$_forestDark" stroke-width="1.4"/>'
          '<rect x="129.5" y="142" width="7" height="6" rx="2" '
          'fill="$_forestDark"/>',
    KairoProp.cup =>
      '<path d="M126 152 L140 152 L138 170 L128 170 Z" fill="$_cream" '
          'stroke="$_gray" stroke-width="1.4"/>'
          '<rect x="125" y="152" width="16" height="4" rx="2" fill="$_hood"/>',
    KairoProp.thumb =>
      '<rect x="130" y="158" width="6" height="10" rx="3" fill="$_skin"/>',
    _ => '',
  };

  /// One shoe, centred on [cx], with the toes pointing left or right.
  String _shoe(double cx, {required bool toesLeft}) {
    final double toe = toesLeft ? -1 : 1;
    return '<path d="M${cx - 9} 197 Q${cx - 10} 208 ${cx - 7} 209 '
        'L${cx + 8 + 7 * toe} 209 Q${cx + 11 + 7 * toe} 208 '
        '${cx + 9 + 6 * toe} 204 Q${cx + 5 * toe} 199 ${cx + 2} 196 Z" '
        'fill="$_hood"/>'
        '<path d="M${cx - 5} 200 L${cx + 4} 203 M${cx - 5} 204 L${cx + 3} 206" '
        'stroke="$_cream" stroke-width="1.5" stroke-linecap="round"/>'
        '<path d="M${cx - 10} 208 L${cx + 10 + 7 * toe} 208 '
        'Q${cx + 13 + 7 * toe} 208 ${cx + 13 + 7 * toe} 212 '
        'Q${cx + 13 + 7 * toe} 216 ${cx + 9 + 7 * toe} 216 L${cx - 9} 216 '
        'Q${cx - 13} 216 ${cx - 13} 212 Q${cx - 13} 208 ${cx - 10} 208 Z" '
        'fill="$_cream" stroke="$_gray" stroke-width="1"/>'
        '<circle cx="${cx + 7 * toe}" cy="204" r="1.1" fill="$_cream" '
        'opacity=".9"/>';
  }

  // ------------------------------------------------------------- confetti --

  /// The eight pieces of confetti that fall while the character celebrates.
  ///
  /// Each piece carries the point it spins about and how far into the fall it
  /// starts, so they do not drop as one line.
  static List<KairoConfettiPiece> get confetti {
    const List<Color> colours = <Color>[
      KairoPalette.forest,
      KairoPalette.mint,
      KairoPalette.cheek,
      KairoPalette.gray,
    ];
    return List<KairoConfettiPiece>.generate(8, (int index) {
      final double x = 30 + index * 20;
      final String colour = KairoPalette.hex(colours[index % 4]);
      if (index.isOdd) {
        return KairoConfettiPiece(
          svg: '<rect x="$x" y="6" width="5" height="8" rx="1" '
              'fill="$colour"/>',
          pivot: Offset(x + 2.5, 10),
          delay: index * 0.17 / 1.8,
        );
      }
      return KairoConfettiPiece(
        svg: '<circle cx="$x" cy="8" r="3.2" fill="$colour"/>',
        pivot: Offset(x, 8),
        delay: index * 0.13 / 1.8,
      );
    });
  }
}

/// One piece of falling confetti.
@immutable
class KairoConfettiPiece {
  /// Describes one piece of confetti.
  const KairoConfettiPiece({
    required this.svg,
    required this.pivot,
    required this.delay,
  });

  /// The piece's drawing, in rig coordinates.
  final String svg;

  /// The point the piece spins about.
  final Offset pivot;

  /// How far into the fall this piece starts, from 0 to 1.
  final double delay;
}
