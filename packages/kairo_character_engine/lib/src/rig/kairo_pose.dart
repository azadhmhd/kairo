import 'package:flutter/painting.dart';

/// Which way the character is facing.
enum KairoView {
  /// Straight at the viewer.
  front,

  /// Turned slightly, drawn as [front] with the face shifted.
  threeQuarter,

  /// In profile.
  side,

  /// Away from the viewer.
  back,
}

/// The six bones every pose and animation moves.
///
/// The side view names its limbs near and far rather than left and right, but
/// they are the same bones with different pivots, so they share these names.
enum KairoJoint {
  /// The left arm; the far arm in [KairoView.side].
  armLeft,

  /// The right arm, which carries every prop; the near arm in
  /// [KairoView.side].
  armRight,

  /// The left leg; the far leg in [KairoView.side].
  legLeft,

  /// The right leg; the near leg in [KairoView.side].
  legRight,

  /// The head.
  head,
}

/// Something the character is holding.
enum KairoProp {
  /// A water bottle, held up to drink from.
  bottle,

  /// A cup of coffee.
  cup,

  /// A raised thumb.
  thumb,

  /// An open book, held in both hands while sitting.
  book,

  /// A laptop, held in both hands while sitting.
  laptop,
}

/// One of the character's nineteen poses.
enum KairoPose {
  /// The rest pose. Every joint at zero.
  standing,

  /// One arm raised to wave.
  waving,

  /// Mid stride.
  walking,

  /// Mid stride, leaning forward.
  running,

  /// Sitting, knees forward.
  sitting,

  /// Both arms above the head.
  stretching,

  /// One arm out, indicating something.
  pointing,

  /// Holding a water bottle up.
  holdingWater,

  /// Holding a cup of coffee.
  holdingCoffee,

  /// Sitting with an open book.
  reading,

  /// Sitting at a laptop.
  typing,

  /// Head tipped, arms loose.
  sleeping,

  /// Off the ground, arms up.
  jumping,

  /// Both arms up.
  celebrating,

  /// One arm out with the thumb raised.
  thumbsUp,

  /// Arms tucked behind, head tilted.
  handsBehindBack,

  /// Looking above the viewer.
  lookingUp,

  /// Looking below the viewer.
  lookingDown,

  /// One hand near the chin.
  thinking,
}

/// Where every joint sits in one pose, in degrees.
///
/// Positive is clockwise, matching the rig's SVG coordinate space. Every value
/// defaults to the rest pose, so a pose only states the joints it actually
/// moves.
class KairoJointAngles {
  /// Describes a pose by the joints it moves away from rest.
  const KairoJointAngles({
    this.armLeft = 0,
    this.armRight = 0,
    this.legLeft = 0,
    this.legRight = 0,
    this.head = 0,
    this.rootRotation = 0,
    this.rootShiftY = 0,
    this.eyeShiftY = 0,
    this.prop,
  });

  /// The left arm's rotation.
  final double armLeft;

  /// The right arm's rotation.
  final double armRight;

  /// The left leg's rotation.
  final double legLeft;

  /// The right leg's rotation.
  final double legRight;

  /// The head's rotation.
  final double head;

  /// How far the whole body leans.
  final double rootRotation;

  /// How far the whole body drops, in rig units. Positive is downwards.
  final double rootShiftY;

  /// How far the eyes look up or down, in rig units. Positive is downwards.
  final double eyeShiftY;

  /// What the character is holding, if anything.
  final KairoProp? prop;

  /// The rotation of one [joint] in this pose.
  double angleOf(KairoJoint joint) => switch (joint) {
    KairoJoint.armLeft => armLeft,
    KairoJoint.armRight => armRight,
    KairoJoint.legLeft => legLeft,
    KairoJoint.legRight => legRight,
    KairoJoint.head => head,
  };

  /// The joint angles each pose is built from.
  static const Map<KairoPose, KairoJointAngles> byPose =
      <KairoPose, KairoJointAngles>{
        KairoPose.standing: KairoJointAngles(),
        KairoPose.waving: KairoJointAngles(armRight: -122, head: -4),
        KairoPose.walking: KairoJointAngles(
          armLeft: 18,
          armRight: -18,
          legLeft: -16,
          legRight: 16,
        ),
        KairoPose.running: KairoJointAngles(
          armLeft: 38,
          armRight: -38,
          legLeft: -32,
          legRight: 32,
          rootRotation: 7,
        ),
        KairoPose.sitting: KairoJointAngles(
          armLeft: -6,
          armRight: 6,
          legLeft: -78,
          legRight: -78,
          rootShiftY: 24,
        ),
        KairoPose.stretching: KairoJointAngles(
          armLeft: 140,
          armRight: -140,
          head: -6,
        ),
        KairoPose.pointing: KairoJointAngles(armRight: -95, head: -3),
        KairoPose.holdingWater: KairoJointAngles(
          armRight: 140,
          prop: KairoProp.bottle,
        ),
        KairoPose.holdingCoffee: KairoJointAngles(
          armRight: 95,
          prop: KairoProp.cup,
        ),
        KairoPose.reading: KairoJointAngles(
          armLeft: -35,
          armRight: 35,
          legLeft: -78,
          legRight: -78,
          rootShiftY: 24,
          head: 7,
          prop: KairoProp.book,
        ),
        KairoPose.typing: KairoJointAngles(
          armLeft: -40,
          armRight: 40,
          legLeft: -78,
          legRight: -78,
          rootShiftY: 24,
          head: 6,
          prop: KairoProp.laptop,
        ),
        KairoPose.sleeping: KairoJointAngles(
          armLeft: -3,
          armRight: 3,
          head: 10,
        ),
        KairoPose.jumping: KairoJointAngles(
          armLeft: 125,
          armRight: -125,
          legLeft: -10,
          legRight: 10,
          rootShiftY: -16,
        ),
        KairoPose.celebrating: KairoJointAngles(
          armLeft: 125,
          armRight: -125,
          head: -4,
        ),
        KairoPose.thumbsUp: KairoJointAngles(
          armRight: -110,
          head: -3,
          prop: KairoProp.thumb,
        ),
        KairoPose.handsBehindBack: KairoJointAngles(
          armLeft: 14,
          armRight: -14,
          head: -3,
        ),
        KairoPose.lookingUp: KairoJointAngles(head: -9, eyeShiftY: -2.5),
        KairoPose.lookingDown: KairoJointAngles(head: 8, eyeShiftY: 2.5),
        KairoPose.thinking: KairoJointAngles(armRight: 138, head: 5),
      };

  /// The joint angles for [pose].
  static KairoJointAngles of(KairoPose pose) =>
      byPose[pose] ?? const KairoJointAngles();
}

/// Where in the rig each moving part turns.
///
/// Everything here is stated in the rig's own 200 by 236 coordinate space, the
/// same space the drawing is in, so these read directly against the character
/// sheet's rigging table.
abstract final class KairoPivots {
  KairoPivots._();

  /// The rig's width, in its own coordinates.
  static const double width = 200;

  /// The rig's height, in its own coordinates.
  static const double height = 236;

  /// Where the whole body leans and hops from: the ground under its feet.
  static const Offset root = Offset(100, 218);

  /// Where the torso expands from when the character breathes: the waist.
  static const Offset breath = Offset(100, 176);

  /// Where the eyes squash from when the character blinks.
  ///
  /// The eyes turn about the centre of their own drawing rather than a point in
  /// the rig, so this is that centre, measured once rather than recomputed from
  /// the drawing on every frame.
  static const Offset eyes = Offset(100, 88);

  /// Where the mouth squashes from while the character talks.
  static const Offset mouth = Offset(100, 108);

  /// Where [joint] turns, in the given [view].
  static Offset of(KairoJoint joint, KairoView view) {
    final bool profile = view == KairoView.side;
    return switch (joint) {
      KairoJoint.armLeft => profile
          ? const Offset(104, 132)
          : const Offset(74, 132),
      KairoJoint.armRight => profile
          ? const Offset(108, 132)
          : const Offset(126, 132),
      KairoJoint.legLeft => profile
          ? const Offset(100, 172)
          : const Offset(90, 172),
      KairoJoint.legRight => profile
          ? const Offset(106, 172)
          : const Offset(110, 172),
      KairoJoint.head => const Offset(100, 124),
    };
  }

  /// [point] expressed as the [Alignment] a [Transform] turns about.
  ///
  /// Every layer of the rig is drawn into a box of the same shape, so a pivot
  /// converts to an alignment once and stays correct at any size the character
  /// is drawn at.
  static Alignment alignment(Offset point) => Alignment(
    point.dx / (width / 2) - 1,
    point.dy / (height / 2) - 1,
  );
}
