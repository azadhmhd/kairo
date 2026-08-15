import 'package:flutter/animation.dart';

import '../rig/kairo_face_parts.dart';
import '../rig/kairo_pose.dart';
import 'kairo_keyframes.dart';

/// What the character is doing.
///
/// A pose says where a joint is; an animation says where it goes, and takes
/// that joint over completely for as long as it runs.
enum KairoAnimation {
  /// Standing, breathing, blinking. The character's resting state, and the
  /// layer every other animation runs on top of.
  idle,

  /// Walking, arms counter-swinging the legs.
  walk,

  /// Running: a wider swing, a faster bob, and a forward lean.
  run,

  /// Waving, with the head tilting along.
  wave,

  /// Both arms up, hopping, with confetti.
  celebrate,

  /// The head rocking slowly, as if working something out.
  think,

  /// Swaying gently, eyes shut. The character does not blink in its sleep.
  sleep,

  /// Both arms reaching up and back down.
  stretch,

  /// Raising something to drink and lowering it again.
  drink,

  /// A single high hop, repeating.
  jump,

  /// Rocking side to side, arms alternating.
  dance,

  /// Looking slowly left and right, eyes leading the head.
  look,

  /// Speaking: the mouth opening and closing, the head moving slightly.
  talk,
}

/// The motion of one [KairoAnimation]: which parts move, and how.
///
/// Every field is a track the animation drives. A track that is null is a part
/// this animation does not touch, which leaves the current pose holding it.
class KairoBehaviour {
  /// Describes an animation by the tracks it drives.
  const KairoBehaviour({
    required this.period,
    this.armLeft,
    this.armRight,
    this.legLeft,
    this.legRight,
    this.head,
    this.rootRotation,
    this.rootShiftX,
    this.rootShiftY,
    this.rootScaleY,
    this.bodyScaleY,
    this.eyeShiftX,
    this.mouthScaleY,
    this.staticRootRotation = 0,
    this.blinks = true,
    this.throwsConfetti = false,
    this.movesSideLimbs = false,
    this.raisesLeftArm = false,
    this.raisesRightArm = false,
  });

  /// How long one turn of this animation takes, before any time scaling.
  ///
  /// Parts that move faster than this state how many times they fit inside it,
  /// rather than each carrying a clock of their own.
  final Duration period;

  /// The left arm's rotation.
  final KairoTrack? armLeft;

  /// The right arm's rotation.
  final KairoTrack? armRight;

  /// The left leg's rotation.
  final KairoTrack? legLeft;

  /// The right leg's rotation.
  final KairoTrack? legRight;

  /// The head's rotation.
  final KairoTrack? head;

  /// How far the whole body leans.
  final KairoTrack? rootRotation;

  /// How far the whole body slides sideways, in rig units.
  final KairoTrack? rootShiftX;

  /// How far the whole body rises and falls, in rig units.
  final KairoTrack? rootShiftY;

  /// How far the whole body squashes and stretches vertically.
  final KairoTrack? rootScaleY;

  /// How far the torso stretches vertically.
  ///
  /// When present this replaces the character's breathing, which is the only
  /// way an animation can silence it.
  final KairoTrack? bodyScaleY;

  /// How far the eyes slide sideways, in rig units.
  final KairoTrack? eyeShiftX;

  /// How far the mouth squashes vertically.
  final KairoTrack? mouthScaleY;

  /// A lean this animation simply holds, on top of anything [rootRotation]
  /// does. Only running has one.
  final double staticRootRotation;

  /// Whether the character blinks during this animation.
  final bool blinks;

  /// Whether confetti falls during this animation.
  final bool throwsConfetti;

  /// Whether this animation moves the limbs in the side view. Only the two
  /// gaits do: in profile the far limb is hidden behind the near one.
  final bool movesSideLimbs;

  /// Whether the left arm is held high enough to pass in front of the body.
  final bool raisesLeftArm;

  /// Whether the right arm is held high enough to pass in front of the body.
  final bool raisesRightArm;

  /// The track driving [joint], or null if this animation leaves it alone.
  KairoTrack? trackFor(KairoJoint joint) => switch (joint) {
    KairoJoint.armLeft => armLeft,
    KairoJoint.armRight => armRight,
    KairoJoint.legLeft => legLeft,
    KairoJoint.legRight => legRight,
    KairoJoint.head => head,
  };

  /// The motion of each animation, transcribed from the character sheet.
  static final Map<KairoAnimation, KairoBehaviour> byAnimation =
      <KairoAnimation, KairoBehaviour>{
        KairoAnimation.idle: const KairoBehaviour(
          period: Duration(seconds: 1),
        ),
        KairoAnimation.walk: KairoBehaviour(
          period: const Duration(milliseconds: 740),
          armLeft: KairoTrack.swing(22, -22),
          armRight: KairoTrack.swing(-22, 22),
          legLeft: KairoTrack.swing(-22, 22),
          legRight: KairoTrack.swing(22, -22),
          rootShiftY: KairoTrack.swing(0, -3, cycles: 2),
          movesSideLimbs: true,
        ),
        KairoAnimation.run: KairoBehaviour(
          period: const Duration(milliseconds: 420),
          armLeft: KairoTrack.swing(38, -38),
          armRight: KairoTrack.swing(-38, 38),
          legLeft: KairoTrack.swing(-38, 38),
          legRight: KairoTrack.swing(38, -38),
          rootShiftY: const KairoTrack(<KairoStop>[
            KairoStop(0, 0),
            KairoStop(0.25, -6),
            KairoStop(0.5, 0),
            KairoStop(0.75, -6),
            KairoStop(1, 0),
          ]),
          rootScaleY: KairoTrack.swing(1, 0.97),
          staticRootRotation: 6,
          movesSideLimbs: true,
        ),
        KairoAnimation.wave: KairoBehaviour(
          period: const Duration(milliseconds: 1800),
          armRight: KairoTrack.swing(-124, -94, cycles: 2),
          head: KairoTrack.swing(-3, 3),
          raisesRightArm: true,
        ),
        KairoAnimation.celebrate: KairoBehaviour(
          period: const Duration(seconds: 1),
          armLeft: KairoTrack.swing(128, 104, cycles: 2),
          armRight: KairoTrack.swing(-104, -128, cycles: 2),
          rootShiftY: const KairoTrack(<KairoStop>[
            KairoStop(0, 0),
            KairoStop(0.12, 2),
            KairoStop(0.45, -16),
            KairoStop(0.8, 0),
            KairoStop(1, 0),
          ]),
          rootScaleY: const KairoTrack(<KairoStop>[
            KairoStop(0, 1),
            KairoStop(0.12, 0.95),
            KairoStop(0.45, 1.03),
            KairoStop(0.8, 1),
            KairoStop(1, 1),
          ]),
          throwsConfetti: true,
          raisesLeftArm: true,
          raisesRightArm: true,
        ),
        KairoAnimation.think: KairoBehaviour(
          period: const Duration(milliseconds: 2400),
          head: KairoTrack.swing(3, 7),
          raisesRightArm: true,
        ),
        KairoAnimation.sleep: KairoBehaviour(
          period: const Duration(seconds: 4),
          rootRotation: KairoTrack.swing(-1.5, 1.5),
          blinks: false,
        ),
        KairoAnimation.stretch: KairoBehaviour(
          period: const Duration(seconds: 3),
          armLeft: KairoTrack.swing(15, 142),
          armRight: KairoTrack.swing(-15, -142),
          bodyScaleY: KairoTrack.swing(1, 1.045),
          raisesLeftArm: true,
          raisesRightArm: true,
        ),
        KairoAnimation.drink: const KairoBehaviour(
          period: Duration(milliseconds: 2600),
          armRight: KairoTrack(<KairoStop>[
            KairoStop(0, 60),
            KairoStop(0.25, 60),
            KairoStop(0.45, 128),
            KairoStop(0.75, 128),
            KairoStop(1, 60),
          ]),
          raisesRightArm: true,
        ),
        KairoAnimation.jump: const KairoBehaviour(
          period: Duration(milliseconds: 1300),
          rootShiftY: KairoTrack(<KairoStop>[
            KairoStop(0, 0),
            KairoStop(0.1, 3),
            KairoStop(0.4, -22),
            KairoStop(0.7, 0),
            KairoStop(0.85, 0),
            KairoStop(1, 0),
          ]),
          rootScaleY: KairoTrack(<KairoStop>[
            KairoStop(0, 1),
            KairoStop(0.1, 0.93),
            KairoStop(0.4, 1.05),
            KairoStop(0.7, 0.96),
            KairoStop(0.85, 1),
            KairoStop(1, 1),
          ]),
          raisesLeftArm: true,
          raisesRightArm: true,
        ),
        KairoAnimation.dance: KairoBehaviour(
          period: const Duration(milliseconds: 1100),
          armLeft: KairoTrack.swing(126, 15),
          armRight: KairoTrack.swing(-15, -126),
          rootRotation: KairoTrack.swing(-5, 5, cycles: 2),
          rootShiftX: KairoTrack.swing(-3, 3, cycles: 2),
          raisesLeftArm: true,
          raisesRightArm: true,
        ),
        KairoAnimation.look: KairoBehaviour(
          period: const Duration(seconds: 4),
          head: KairoTrack.swing(-8, 8),
          eyeShiftX: KairoTrack.swing(-2.5, 2.5),
        ),
        KairoAnimation.talk: KairoBehaviour(
          period: const Duration(milliseconds: 1400),
          head: KairoTrack.swing(0, 1.6),
          mouthScaleY: KairoTrack.swing(1, 0.45, cycles: 5),
        ),
      };

  /// The motion of [animation].
  static KairoBehaviour of(KairoAnimation animation) =>
      byAnimation[animation] ?? byAnimation[KairoAnimation.idle]!;
}

/// The motions that run underneath every animation, and beside every symbol.
///
/// Breathing and blinking are not animations the caller picks. They run
/// whatever else the character is doing, on clocks of their own, which is what
/// keeps the character looking alive while it stands still.
abstract final class KairoIdleMotion {
  KairoIdleMotion._();

  /// How long one breath takes.
  static const Duration breathPeriod = Duration(milliseconds: 3800);

  /// How long one blink cycle takes. The blink itself is a moment inside it.
  static const Duration blinkPeriod = Duration(milliseconds: 4600);

  /// How far the torso stretches as the character breathes in.
  static final KairoTrack breathScaleY = KairoTrack.swing(1, 1.02);

  /// How far the torso rises as the character breathes in, in rig units.
  static final KairoTrack breathShiftY = KairoTrack.swing(0, -1.6);

  /// How far the eyes squash. Flat for most of the cycle, then a fast shut.
  static const KairoTrack blinkScaleY = KairoTrack(<KairoStop>[
    KairoStop(0, 1),
    KairoStop(0.935, 1),
    KairoStop(0.96, 0.07),
    KairoStop(1, 1),
  ], curve: Curves.ease);

  /// How long each kind of floating symbol takes to complete one cycle.
  static Duration periodOf(KairoExtraMotion motion) => switch (motion) {
    KairoExtraMotion.drift => const Duration(milliseconds: 1800),
    KairoExtraMotion.pulse => const Duration(milliseconds: 1400),
    KairoExtraMotion.rise => const Duration(milliseconds: 2600),
    KairoExtraMotion.twinkle => const Duration(milliseconds: 1200),
  };

  /// How far a drifting symbol rises and falls, in rig units.
  static final KairoTrack driftShiftY = KairoTrack.swing(0, -4);

  /// How a pulsing symbol fades in and out.
  static final KairoTrack pulseOpacity = KairoTrack.swing(
    0.25,
    1,
    curve: Curves.ease,
  );

  /// How far a rising symbol travels sideways, in rig units.
  static const KairoTrack riseShiftX = KairoTrack(<KairoStop>[
    KairoStop(0, 0),
    KairoStop(1, 8),
  ]);

  /// How far a rising symbol travels upwards, in rig units.
  static const KairoTrack riseShiftY = KairoTrack(<KairoStop>[
    KairoStop(0, 6),
    KairoStop(1, -14),
  ]);

  /// How a rising symbol fades in and then away.
  static const KairoTrack riseOpacity = KairoTrack(<KairoStop>[
    KairoStop(0, 0),
    KairoStop(0.4, 1),
    KairoStop(1, 0),
  ]);

  /// How far a twinkling symbol scales.
  static final KairoTrack twinkleScale = KairoTrack.swing(0.7, 1.15);

  /// How a twinkling symbol brightens.
  static final KairoTrack twinkleOpacity = KairoTrack.swing(0.5, 1);

  /// How long one piece of confetti takes to fall.
  static const Duration confettiPeriod = Duration(milliseconds: 1800);

  /// How far a piece of confetti falls, in rig units.
  static const KairoTrack confettiShiftY = KairoTrack(
    <KairoStop>[KairoStop(0, -10), KairoStop(1, 210)],
    curve: Curves.linear,
  );

  /// How far a piece of confetti spins, in degrees.
  static const KairoTrack confettiRotation = KairoTrack(
    <KairoStop>[KairoStop(0, 0), KairoStop(1, 240)],
    curve: Curves.linear,
  );

  /// How a piece of confetti fades as it falls.
  static const KairoTrack confettiOpacity = KairoTrack(
    <KairoStop>[KairoStop(0, 1), KairoStop(1, 0)],
    curve: Curves.linear,
  );
}
