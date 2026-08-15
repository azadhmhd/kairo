import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'kairo_expression.dart';
import 'kairo_palette.dart';

/// How one floating symbol beside the head moves.
enum KairoExtraMotion {
  /// Drifts gently up and down.
  drift,

  /// Fades in and out on the spot.
  pulse,

  /// Rises away and fades, the motion of a sleep mark.
  rise,

  /// Scales and brightens, the motion of a sparkle.
  twinkle,
}

/// One drawn piece of a [KairoExtra], with the motion it is given.
///
/// A symbol is not always a single shape: thinking is three dots that pulse in
/// sequence, and sleep is three `z`s that rise one after another. Each piece
/// carries its own delay so the sequence reads as a sequence.
@immutable
class KairoExtraPiece {
  /// Describes one piece of a floating symbol.
  const KairoExtraPiece({
    required this.svg,
    required this.motion,
    this.pivot = Offset.zero,
    this.delay = 0,
  });

  /// The piece's drawing, in rig coordinates.
  final String svg;

  /// How the piece moves.
  final KairoExtraMotion motion;

  /// The point the piece scales about, for [KairoExtraMotion.twinkle].
  final Offset pivot;

  /// How far into the cycle this piece starts, from 0 to 1.
  final double delay;
}

/// The drawings of the character's face, and of the symbols beside it.
///
/// Every string here is a fragment of SVG in the rig's own coordinate space.
/// Nothing in this class knows how large the character will be drawn or what it
/// is doing; it only knows what each shape looks like.
abstract final class KairoFaceParts {
  KairoFaceParts._();

  /// The gradient the irises are filled with.
  ///
  /// Each layer of the rig is parsed as a document of its own, so any layer
  /// that draws an eye has to carry this definition itself.
  static String get irisGradient =>
      '<defs><radialGradient id="irisG" cx="50%" cy="35%" r="75%">'
      '<stop offset="0%" stop-color="${KairoPalette.hex(KairoPalette.iris[0])}"/>'
      '<stop offset="55%" stop-color="${KairoPalette.hex(KairoPalette.iris[1])}"/>'
      '<stop offset="100%" stop-color="${KairoPalette.hex(KairoPalette.iris[2])}"/>'
      '</radialGradient></defs>';

  static final String _hair = KairoPalette.hex(KairoPalette.hair);
  static final String _skinShaded = KairoPalette.hex(KairoPalette.skinShaded);
  static final String _skin = KairoPalette.hex(KairoPalette.skin);
  static final String _line = KairoPalette.hex(KairoPalette.line);
  static final String _mouthInside = KairoPalette.hex(KairoPalette.mouth);
  static final String _forest = KairoPalette.hex(KairoPalette.forest);

  /// The stroke every facial line is drawn with.
  static final String _facialLine =
      'stroke="$_line" stroke-width="2.6" fill="none" stroke-linecap="round"';

  /// Both eyes, drawn for the front and three-quarter views.
  ///
  /// A wink is the only asymmetric shape: the left eye stays open while the
  /// right one closes.
  static String eyes(KairoEye type) {
    final KairoEye left = type == KairoEye.wink ? KairoEye.open : type;
    final KairoEye right = type == KairoEye.wink ? KairoEye.closedUp : type;
    return '${_eye(80, 88, left)}${_eye(120, 88, right)}';
  }

  /// The single visible eye in the side view.
  ///
  /// The profile has no room for the shapes that depend on seeing both eyes, so
  /// anything other than a closed eye is drawn open.
  static String sideEye(KairoEye type) {
    final bool closed =
        type == KairoEye.closedUp || type == KairoEye.closedDown;
    return _eye(129, 88, closed ? type : KairoEye.open);
  }

  static String _lash(double cx, double cy, double radiusY) =>
      '<path d="M${cx - 10} ${cy - radiusY + 1.5} Q$cx ${cy - radiusY - 4} '
      '${cx + 10} ${cy - radiusY + 1.5}" stroke="$_hair" stroke-width="3" '
      'fill="none" stroke-linecap="round"/>';

  /// An open eye of the given size, with the iris pushed by [shiftX], [shiftY].
  static String _openEye(
    double cx,
    double cy,
    double radiusX,
    double radiusY,
    double shiftX,
    double shiftY,
  ) =>
      '<ellipse cx="$cx" cy="$cy" rx="${radiusX + 1.8}" '
      'ry="${radiusY + 1.2}" fill="#ffffff"/>'
      '<ellipse cx="${cx + shiftX * 0.6}" cy="$cy" rx="$radiusX" '
      'ry="$radiusY" fill="url(#irisG)"/>'
      '<ellipse cx="${cx + shiftX * 0.8}" cy="${cy + shiftY * 0.5 + 0.5}" '
      'rx="${radiusX * 0.42}" ry="${radiusY * 0.42}" '
      'fill="${KairoPalette.hex(KairoPalette.pupil)}"/>'
      '<circle cx="${cx + shiftX - 2.8}" cy="${cy + shiftY - 3.8}" r="2.8" '
      'fill="#ffffff"/>'
      '<circle cx="${cx + shiftX + 2.6}" cy="${cy + shiftY + 3.2}" r="1.3" '
      'fill="#ffffff" opacity=".9"/>'
      '<path d="M${cx - radiusX + 1} ${cy + radiusY + 2} Q$cx '
      '${cy + radiusY + 4} ${cx + radiusX - 1} ${cy + radiusY + 2}" '
      'stroke="$_skinShaded" stroke-width="1.6" fill="none" '
      'stroke-linecap="round" opacity=".7"/>'
      '${_lash(cx, cy, radiusY + 1.2)}';

  static String _eye(double cx, double cy, KairoEye type) {
    switch (type) {
      case KairoEye.open:
      case KairoEye.wink:
        return _openEye(cx, cy, 7, 9, 0, 0);
      case KairoEye.wide:
        return _openEye(cx, cy, 8.2, 10.2, 0, 0);
      case KairoEye.glancing:
        return _openEye(cx, cy, 7, 9, 3, -1.5);
      case KairoEye.half:
        return '${_openEye(cx, cy, 7, 9, 0, 1)}'
            '<path d="M${cx - 10} ${cy - 3} Q$cx ${cy - 6.5} ${cx + 10} '
            '${cy - 3} L${cx + 10} ${cy - 14} L${cx - 10} ${cy - 14} Z" '
            'fill="$_skin"/>'
            '<path d="M${cx - 10} ${cy - 3} Q$cx ${cy - 6.5} ${cx + 10} '
            '${cy - 3}" stroke="$_hair" stroke-width="2.6" fill="none" '
            'stroke-linecap="round"/>';
      case KairoEye.drooping:
        return _openEye(cx, cy, 6.2, 7.6, 0, 1.5);
      case KairoEye.star:
        return '<ellipse cx="$cx" cy="$cy" rx="9.2" ry="10.6" fill="#ffffff"/>'
            '<ellipse cx="$cx" cy="$cy" rx="7.4" ry="9.2" fill="url(#irisG)"/>'
            '<path d="M$cx ${cy - 5.5} L${cx + 1.5} ${cy - 1.5} L${cx + 5.5} '
            '$cy L${cx + 1.5} ${cy + 1.5} L$cx ${cy + 5.5} L${cx - 1.5} '
            '${cy + 1.5} L${cx - 5.5} $cy L${cx - 1.5} ${cy - 1.5} Z" '
            'fill="#ffffff"/>'
            '${_lash(cx, cy, 10.4)}';
      case KairoEye.closedUp:
        return '<path d="M${cx - 8.5} ${cy + 2} Q$cx ${cy - 7} ${cx + 8.5} '
            '${cy + 2}" stroke="$_hair" stroke-width="2.8" fill="none" '
            'stroke-linecap="round"/>';
      case KairoEye.closedDown:
        return '<path d="M${cx - 8} ${cy - 1} Q$cx ${cy + 5} ${cx + 8} '
            '${cy - 1}" stroke="$_hair" stroke-width="2.6" fill="none" '
            'stroke-linecap="round"/>';
    }
  }

  /// Both brows.
  static String brows(KairoBrow type) {
    const String stroke =
        'stroke-width="3" fill="none" stroke-linecap="round"';
    final (String, String) shapes = switch (type) {
      KairoBrow.flat => ('M70 72 Q78 69.5 86 72', 'M114 72 Q122 69.5 130 72'),
      KairoBrow.raised => ('M70 69 Q78 64 86 68', 'M114 68 Q122 64 130 69'),
      KairoBrow.sad => ('M70 74 Q79 69 86 68', 'M114 68 Q121 69 130 74'),
      KairoBrow.lowered => ('M70 68 Q78 71 86 74', 'M114 74 Q122 71 130 68'),
      KairoBrow.asymmetric => (
        'M70 66 Q78 62 86 66',
        'M114 72 Q122 69.5 130 72',
      ),
    };
    return '<path d="${shapes.$1}" stroke="$_hair" $stroke/>'
        '<path d="${shapes.$2}" stroke="$_hair" $stroke/>';
  }

  /// The mouth, drawn for the front and three-quarter views.
  static String mouth(KairoMouth type) => switch (type) {
    KairoMouth.smile => '<path d="M91 106 Q100 114 109 106" $_facialLine/>',
    KairoMouth.smallSmile =>
      '<path d="M95 107 Q100 111.5 105 107" $_facialLine/>',
    KairoMouth.bigSmile =>
      '<path d="M90 105 Q100 119 110 105 Q100 111 90 105 Z" '
          'fill="$_mouthInside"/>'
          '<path d="M90 105 Q100 111 110 105" $_facialLine/>',
    KairoMouth.laugh =>
      '<path d="M90 104 Q100 124 110 104 Q100 109 90 104 Z" '
          'fill="$_mouthInside"/>'
          '<path d="M94 114 Q100 120 106 114 Q100 116 94 114 Z" '
          'fill="${KairoPalette.hex(KairoPalette.tongue)}"/>',
    KairoMouth.round => '<circle cx="100" cy="108" r="3.4" '
        'fill="$_mouthInside"/>',
    KairoMouth.tallRound =>
      '<ellipse cx="100" cy="109" rx="4.4" ry="6" fill="$_mouthInside"/>',
    KairoMouth.flat => '<path d="M94 108.5 L106 108.5" $_facialLine/>',
    KairoMouth.frown => '<path d="M92 111 Q100 104.5 108 111" $_facialLine/>',
    KairoMouth.wavy =>
      '<path d="M92 109 Q96 106.5 100 109 Q104 111.5 108 109" $_facialLine/>',
    KairoMouth.determined =>
      '<path d="M93 109 L107 109" stroke="$_line" stroke-width="3.2" '
          'fill="none" stroke-linecap="round"/>',
    KairoMouth.small => '<path d="M97 108 Q100 110 103 108" $_facialLine/>',
  };

  /// The nose, drawn for the front and three-quarter views.
  static String get nose =>
      '<path d="M98 99 Q100 102 102 99" stroke="$_skinShaded" '
      'stroke-width="2" fill="none" stroke-linecap="round"/>';

  /// Both cheeks, at the [opacity] the current expression calls for.
  static String blush(double opacity) =>
      '<ellipse cx="66" cy="102" rx="6.5" ry="3.6" '
      'fill="${KairoPalette.hex(KairoPalette.cheek)}" opacity="$opacity"/>'
      '<ellipse cx="134" cy="102" rx="6.5" ry="3.6" '
      'fill="${KairoPalette.hex(KairoPalette.cheek)}" opacity="$opacity"/>';

  /// The face in the side view, which does not vary with expression.
  ///
  /// A profile shows one brow, one eye and the corner of a mouth. There is not
  /// enough of the face left to carry sixteen expressions, so the character
  /// sheet draws one and lets the pose and the animation do the work.
  static String get sideFace =>
      '<path d="M120 70 Q128 66 136 69" stroke="$_hair" stroke-width="3" '
      'fill="none" stroke-linecap="round"/>'
      '<path d="M148 96 Q152 99 149 102" stroke="$_skinShaded" '
      'stroke-width="2.2" fill="none" stroke-linecap="round"/>'
      '<path d="M136 108 Q141 111 145 107" stroke="$_line" '
      'stroke-width="2.4" fill="none" stroke-linecap="round"/>'
      '<ellipse cx="122" cy="102" rx="6" ry="3.4" '
      'fill="${KairoPalette.hex(KairoPalette.cheek)}" opacity=".5"/>';

  /// The pieces that make up the symbol floating beside the head.
  static List<KairoExtraPiece> extras(KairoExtra kind) {
    switch (kind) {
      case KairoExtra.question:
        return <KairoExtraPiece>[
          KairoExtraPiece(
            svg: '<text x="146" y="52" font-size="26" font-weight="800" '
                'fill="$_forest">?</text>',
            motion: KairoExtraMotion.drift,
          ),
        ];
      case KairoExtra.exclamation:
        return <KairoExtraPiece>[
          KairoExtraPiece(
            svg: '<text x="146" y="50" font-size="26" font-weight="800" '
                'fill="$_forest">!</text>',
            motion: KairoExtraMotion.drift,
          ),
        ];
      case KairoExtra.dots:
        // Delays of 0, 0.25s and 0.5s across a 1.4s cycle.
        return <KairoExtraPiece>[
          KairoExtraPiece(
            svg: '<circle cx="140" cy="48" r="2.6" fill="$_forest"/>',
            motion: KairoExtraMotion.pulse,
          ),
          KairoExtraPiece(
            svg: '<circle cx="149" cy="44" r="3.2" fill="$_forest"/>',
            motion: KairoExtraMotion.pulse,
            delay: 0.25 / 1.4,
          ),
          KairoExtraPiece(
            svg: '<circle cx="159" cy="40" r="3.8" fill="$_forest"/>',
            motion: KairoExtraMotion.pulse,
            delay: 0.5 / 1.4,
          ),
        ];
      case KairoExtra.tear:
        return <KairoExtraPiece>[
          KairoExtraPiece(
            svg: '<path d="M66 98 Q62 106 66 109 Q70 106 66 98 Z" '
                'fill="${KairoPalette.hex(KairoPalette.water)}"/>',
            motion: KairoExtraMotion.drift,
          ),
        ];
      case KairoExtra.sweat:
        return <KairoExtraPiece>[
          KairoExtraPiece(
            svg: '<path d="M142 58 Q137 68 142 72 Q147 68 142 58 Z" '
                'fill="${KairoPalette.hex(KairoPalette.water)}"/>',
            motion: KairoExtraMotion.drift,
          ),
        ];
      case KairoExtra.sleepMarks:
        // Delays of 0, 0.8s and 1.6s across a 2.6s cycle.
        final String coal = KairoPalette.hex(KairoPalette.coal);
        return <KairoExtraPiece>[
          KairoExtraPiece(
            svg: '<text x="140" y="52" font-size="18" font-weight="800" '
                'fill="$coal">z</text>',
            motion: KairoExtraMotion.rise,
          ),
          KairoExtraPiece(
            svg: '<text x="152" y="40" font-size="14" font-weight="800" '
                'fill="$coal">z</text>',
            motion: KairoExtraMotion.rise,
            delay: 0.8 / 2.6,
          ),
          KairoExtraPiece(
            svg: '<text x="161" y="31" font-size="11" font-weight="800" '
                'fill="$coal">z</text>',
            motion: KairoExtraMotion.rise,
            delay: 1.6 / 2.6,
          ),
        ];
      case KairoExtra.sparkles:
        final String mint = KairoPalette.hex(KairoPalette.mint);
        return <KairoExtraPiece>[
          KairoExtraPiece(
            svg: '<path d="M52 52 l2 5 5 2 -5 2 -2 5 -2 -5 -5 -2 5 -2 Z" '
                'fill="$mint"/>',
            motion: KairoExtraMotion.twinkle,
            pivot: const Offset(52, 59),
          ),
          KairoExtraPiece(
            svg: '<path d="M148 40 l1.6 4 4 1.6 -4 1.6 -1.6 4 -1.6 -4 -4 -1.6 '
                '4 -1.6 Z" fill="$mint"/>',
            motion: KairoExtraMotion.twinkle,
            pivot: const Offset(148, 45.6),
          ),
        ];
    }
  }
}
