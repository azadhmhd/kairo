/// The behaviour of Kairo's character: animation, dialogue, emotion, presence.
///
/// The character reacts to what the rest of the application tells it and never
/// decides anything on its own. It knows nothing about reminders, workflows or
/// storage; those layers drive it through this package's API.
///
/// What is here so far is the character itself: [KairoCharacter], a rig ported
/// from the approved character sheet in `assets/rive/`. It is a widget and
/// nothing more — hand it a view, an expression, a pose and an animation, and
/// it draws exactly that. Deciding which of those Kairo should be in belongs to
/// the behaviour layer, which arrives with Milestone 4.
library;

export 'src/animation/kairo_behaviour.dart'
    show KairoAnimation, KairoBehaviour, KairoIdleMotion;
export 'src/animation/kairo_keyframes.dart' show KairoStop, KairoTrack;
export 'src/rig/kairo_body_parts.dart' show KairoBodyParts, KairoConfettiPiece;
export 'src/rig/kairo_expression.dart'
    show
        KairoBrow,
        KairoExpression,
        KairoExtra,
        KairoEye,
        KairoFace,
        KairoMouth;
export 'src/rig/kairo_face_parts.dart'
    show KairoExtraMotion, KairoExtraPiece, KairoFaceParts;
export 'src/rig/kairo_palette.dart' show KairoPalette;
export 'src/rig/kairo_pose.dart'
    show
        KairoJoint,
        KairoJointAngles,
        KairoPivots,
        KairoPose,
        KairoProp,
        KairoView;
export 'src/widget/kairo_character.dart' show KairoCharacter;
