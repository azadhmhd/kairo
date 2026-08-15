/// How the character's brows are shaped.
enum KairoBrow {
  /// Level and relaxed.
  flat,

  /// Lifted, the shape behind every warm expression.
  raised,

  /// Inner ends lifted, outer ends dropped.
  sad,

  /// Inner ends dropped: concentration, not anger.
  lowered,

  /// One raised and one flat, which reads as thinking.
  asymmetric,
}

/// How the character's eyes are drawn.
enum KairoEye {
  /// The default open eye.
  open,

  /// Opened wider, for surprise and curiosity.
  wide,

  /// Open, with the iris pushed to one side.
  glancing,

  /// Half lidded.
  half,

  /// Open but smaller and lower, which reads as tired or sad.
  drooping,

  /// A star in place of the pupil.
  star,

  /// Closed with the lids curving up, the shape of a smile.
  closedUp,

  /// Closed with the lids curving down, the shape of sleep.
  closedDown,

  /// The left eye [open] and the right eye [closedUp].
  wink,
}

/// How the character's mouth is drawn.
enum KairoMouth {
  /// The default smile.
  smile,

  /// A smaller, more restrained smile.
  smallSmile,

  /// An open smile.
  bigSmile,

  /// A wide open mouth with the tongue showing.
  laugh,

  /// A small round mouth.
  round,

  /// A taller oval mouth, for surprise.
  tallRound,

  /// A straight line.
  flat,

  /// An inverted smile.
  frown,

  /// A wavering line, for worry.
  wavy,

  /// A heavier straight line, for determination.
  determined,

  /// A very small curve.
  small,
}

/// The small symbols that float beside the character's head.
enum KairoExtra {
  /// A question mark.
  question,

  /// An exclamation mark.
  exclamation,

  /// Three rising dots, which read as thought.
  dots,

  /// A single tear.
  tear,

  /// A drop of sweat.
  sweat,

  /// Rising `z`s.
  sleepMarks,

  /// Two pulsing sparkles.
  sparkles,
}

/// One of the character's sixteen faces.
///
/// An expression is not a drawing. It is a choice of brow, eye and mouth shape,
/// an optional floating symbol, and how strong the blush is — which is why
/// sixteen of them cost four swappable layers rather than sixteen pictures.
enum KairoExpression {
  /// Warm and open. The character's resting face when something has gone well.
  happy,

  /// Working something out.
  thinking,

  /// Interested in what the user just did.
  curious,

  /// Delighted.
  excited,

  /// Pleased with the user, not with itself.
  proud,

  /// Sorry, never reproachful.
  sad,

  /// Worried on the user's behalf.
  concerned,

  /// Patiently waiting to be noticed.
  waiting,

  /// Asleep.
  sleeping,

  /// Laughing.
  laughing,

  /// Celebrating something the user finished.
  celebrating,

  /// Bashful.
  shy,

  /// Encouraging the user to keep going.
  encouraging,

  /// Startled.
  surprised,

  /// Concentrating.
  focused,

  /// The default face, used whenever nothing else has been asked for.
  neutral,
}

/// The layers that make up one [KairoExpression].
class KairoFace {
  /// Describes a face built from the given layers.
  const KairoFace({
    required this.brow,
    required this.eye,
    required this.mouth,
    this.extra,
    this.blush = 0.5,
  });

  /// The brow shape.
  final KairoBrow brow;

  /// The eye shape.
  final KairoEye eye;

  /// The mouth shape.
  final KairoMouth mouth;

  /// The symbol floating beside the head, if this face has one.
  final KairoExtra? extra;

  /// How opaque the blush is, from 0 to 1.
  final double blush;

  /// The face each expression is drawn with.
  static const Map<KairoExpression, KairoFace> byExpression =
      <KairoExpression, KairoFace>{
        KairoExpression.happy: KairoFace(
          brow: KairoBrow.raised,
          eye: KairoEye.open,
          mouth: KairoMouth.smile,
        ),
        KairoExpression.thinking: KairoFace(
          brow: KairoBrow.asymmetric,
          eye: KairoEye.glancing,
          mouth: KairoMouth.flat,
          extra: KairoExtra.dots,
        ),
        KairoExpression.curious: KairoFace(
          brow: KairoBrow.raised,
          eye: KairoEye.wide,
          mouth: KairoMouth.round,
          extra: KairoExtra.question,
        ),
        KairoExpression.excited: KairoFace(
          brow: KairoBrow.raised,
          eye: KairoEye.star,
          mouth: KairoMouth.bigSmile,
        ),
        KairoExpression.proud: KairoFace(
          brow: KairoBrow.raised,
          eye: KairoEye.closedUp,
          mouth: KairoMouth.bigSmile,
        ),
        KairoExpression.sad: KairoFace(
          brow: KairoBrow.sad,
          eye: KairoEye.drooping,
          mouth: KairoMouth.frown,
          extra: KairoExtra.tear,
        ),
        KairoExpression.concerned: KairoFace(
          brow: KairoBrow.sad,
          eye: KairoEye.open,
          mouth: KairoMouth.wavy,
          extra: KairoExtra.sweat,
        ),
        KairoExpression.waiting: KairoFace(
          brow: KairoBrow.flat,
          eye: KairoEye.half,
          mouth: KairoMouth.flat,
        ),
        KairoExpression.sleeping: KairoFace(
          brow: KairoBrow.flat,
          eye: KairoEye.closedDown,
          mouth: KairoMouth.small,
          extra: KairoExtra.sleepMarks,
        ),
        KairoExpression.laughing: KairoFace(
          brow: KairoBrow.raised,
          eye: KairoEye.closedUp,
          mouth: KairoMouth.laugh,
        ),
        KairoExpression.celebrating: KairoFace(
          brow: KairoBrow.raised,
          eye: KairoEye.star,
          mouth: KairoMouth.laugh,
          extra: KairoExtra.sparkles,
        ),
        KairoExpression.shy: KairoFace(
          brow: KairoBrow.sad,
          eye: KairoEye.glancing,
          mouth: KairoMouth.smallSmile,
          blush: 0.85,
        ),
        KairoExpression.encouraging: KairoFace(
          brow: KairoBrow.raised,
          eye: KairoEye.wink,
          mouth: KairoMouth.smile,
          extra: KairoExtra.sparkles,
        ),
        KairoExpression.surprised: KairoFace(
          brow: KairoBrow.raised,
          eye: KairoEye.wide,
          mouth: KairoMouth.tallRound,
          extra: KairoExtra.exclamation,
        ),
        KairoExpression.focused: KairoFace(
          brow: KairoBrow.lowered,
          eye: KairoEye.half,
          mouth: KairoMouth.determined,
        ),
        KairoExpression.neutral: KairoFace(
          brow: KairoBrow.flat,
          eye: KairoEye.open,
          mouth: KairoMouth.smallSmile,
        ),
      };

  /// The face for [expression].
  static KairoFace of(KairoExpression expression) =>
      byExpression[expression] ?? byExpression[KairoExpression.neutral]!;
}
