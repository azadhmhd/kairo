import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../animation/kairo_behaviour.dart';
import '../animation/kairo_keyframes.dart';
import '../rig/kairo_body_parts.dart';
import '../rig/kairo_expression.dart';
import '../rig/kairo_face_parts.dart';
import '../rig/kairo_palette.dart';
import '../rig/kairo_pose.dart';

/// Kairo, drawn.
///
/// A rig, not a picture: a fixed set of layers moved by turning them about the
/// joints they hang from. Every combination of view, expression, pose and
/// animation is those same layers at different angles.
///
/// The widget draws and nothing else — it decides nothing and reaches for
/// nothing outside itself, including the mouse pointer, which the caller
/// supplies through [lookAt]. That is what makes it safe in the character
/// window, which has no providers and no event bus.
class KairoCharacter extends StatefulWidget {
  /// Draws the character in the given state.
  const KairoCharacter({
    super.key,
    this.view = KairoView.front,
    this.expression = KairoExpression.neutral,
    this.pose = KairoPose.standing,
    this.animation = KairoAnimation.idle,
    this.size = 200,
    this.hoodie = KairoPalette.forest,
    this.timeScale = 1,
    this.phase = 0,
    this.flipped = false,
    this.hasShadow = true,
    this.paused = false,
    this.lookAt,
  }) : assert(size > 0, 'the character has to have a size'),
       assert(timeScale > 0, 'time cannot stand still or run backwards');

  /// Which way the character is facing.
  final KairoView view;

  /// The character's face.
  final KairoExpression expression;

  /// Where the character's joints rest.
  ///
  /// An [animation] that drives a joint takes it over completely, so a pose is
  /// only visible in the joints the current animation leaves alone.
  final KairoPose pose;

  /// What the character is doing.
  final KairoAnimation animation;

  /// How wide the character is drawn, in logical pixels.
  ///
  /// The height follows from the rig's proportions, and is always 1.18 times
  /// this.
  final double size;

  /// The hoodie's colour. Also the shoes', and the cup's rim.
  final Color hoodie;

  /// A multiplier on every duration.
  ///
  /// Larger is slower: 2 plays at half speed, 0.5 at double. This matches the
  /// character sheet, whose control scales durations rather than rates.
  final double timeScale;

  /// Where in its cycle the animation starts, from 0 to 1.
  ///
  /// Keeps two characters on screen from breathing in step, and together with
  /// [paused] freezes a cycle at a chosen frame.
  final double phase;

  /// Whether the character is mirrored, so it faces the other way.
  final bool flipped;

  /// Whether the soft ellipse is drawn on the ground beneath the character.
  ///
  /// Turn it off when the character stands on something that has a shadow of
  /// its own, or on nothing at all.
  final bool hasShadow;

  /// Whether the character holds still.
  ///
  /// A paused character resumes from where it stopped rather than from the
  /// start of its cycle.
  final bool paused;

  /// Where the character should look, as a point from (-1, -1) to (1, 1), with
  /// the origin straight ahead. Null looks straight out.
  ///
  /// Supplied by the caller rather than found here: the character window
  /// receives no mouse events, which is exactly what lets clicks fall through
  /// it, so only the caller can know where the pointer is.
  final Offset? lookAt;

  /// The height the character is drawn at, given its [size].
  double get height => size * KairoPivots.height / KairoPivots.width;

  @override
  State<KairoCharacter> createState() => _KairoCharacterState();
}

class _KairoCharacterState extends State<KairoCharacter>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  /// How long the character has been moving — not how long it has existed.
  /// Time stops accumulating while it is paused, so it resumes where it left
  /// off.
  double _seconds = 0;
  Duration _lastFrame = Duration.zero;

  late _RigLayers _layers;

  @override
  void initState() {
    super.initState();
    _layers = _buildLayers();
    _ticker = createTicker(_onFrame)..start();
  }

  @override
  void didUpdateWidget(KairoCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The drawings only change when the drawing changes. An animation running
    // over them changes angles, not shapes.
    if (widget.view != oldWidget.view ||
        widget.expression != oldWidget.expression ||
        widget.pose != oldWidget.pose ||
        widget.hoodie != oldWidget.hoodie ||
        widget.hasShadow != oldWidget.hasShadow) {
      _layers = _buildLayers();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onFrame(Duration elapsed) {
    final Duration delta = elapsed - _lastFrame;
    _lastFrame = elapsed;
    if (widget.paused) {
      return;
    }
    setState(() {
      _seconds += delta.inMicroseconds / Duration.microsecondsPerSecond;
    });
  }

  KairoFace get _face => KairoFace.of(widget.expression);

  KairoJointAngles get _angles => KairoJointAngles.of(widget.pose);

  KairoBehaviour get _behaviour => KairoBehaviour.of(widget.animation);

  /// Whether this view shows the face and honours poses, rather than being a
  /// profile or the back of the head.
  bool get _facing =>
      widget.view == KairoView.front || widget.view == KairoView.threeQuarter;

  /// How far through a cycle of the given length the character is.
  double _cycle(Duration period) =>
      _seconds *
      Duration.microsecondsPerSecond /
      (period.inMicroseconds * widget.timeScale);

  /// How far through the current animation the character is.
  double get _action => _cycle(_behaviour.period) + widget.phase;

  /// One rig unit, in logical pixels.
  double get _unit => widget.size / KairoPivots.width;

  // ------------------------------------------------------------- assembly --

  @override
  Widget build(BuildContext context) {
    Widget character = Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: <Widget>[
        if (_layers.shadow != null) _layers.shadow!,
        _root(),
      ],
    );

    if (widget.flipped) {
      character = Transform.scale(scaleX: -1, child: character);
    }

    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.height,
        child: character,
      ),
    );
  }

  /// Everything that leans, hops and breathes: the character itself.
  Widget _root() {
    final KairoBehaviour behaviour = _behaviour;
    final bool animatesRoot =
        behaviour.rootRotation != null ||
        behaviour.rootShiftX != null ||
        behaviour.rootShiftY != null ||
        behaviour.rootScaleY != null;

    Widget body = _breathing(_parts());

    // A pose's drop hangs from its own layer in the rig, so an animation moving
    // the root never cancels it: the character stays seated while it reads.
    if (_facing && _angles.rootShiftY != 0) {
      body = Transform.translate(
        offset: Offset(0, _angles.rootShiftY * _unit),
        child: body,
      );
    }

    // The confetti hangs from the root rather than from the body, so it hops
    // with the character but does not breathe or sit down with it.
    if (behaviour.throwsConfetti) {
      body = Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: <Widget>[body, ..._confetti()],
      );
    }

    if (behaviour.rootScaleY != null) {
      body = Transform.scale(
        scaleY: behaviour.rootScaleY!.at(_action),
        alignment: KairoPivots.alignment(KairoPivots.root),
        child: body,
      );
    }

    if (behaviour.rootShiftX != null || behaviour.rootShiftY != null) {
      body = Transform.translate(
        offset: Offset(
          (behaviour.rootShiftX?.at(_action) ?? 0) * _unit,
          (behaviour.rootShiftY?.at(_action) ?? 0) * _unit,
        ),
        child: body,
      );
    }

    // An animation that turns the root replaces the pose's lean outright, the
    // way an animation replaces the inline transform it competes with. The lean
    // a run simply holds is a separate thing, and adds to whichever won.
    final double lean =
        (animatesRoot
            ? (behaviour.rootRotation?.at(_action) ?? 0)
            : (_facing ? _angles.rootRotation : 0)) +
        behaviour.staticRootRotation;
    if (lean != 0) {
      body = Transform.rotate(
        angle: _radians(lean),
        alignment: KairoPivots.alignment(KairoPivots.root),
        child: body,
      );
    }

    return body;
  }

  /// The torso rising and falling, which runs under everything else.
  Widget _breathing(Widget child) {
    // Stretching takes the breath over: the character is already expanding its
    // chest as far as it goes.
    final KairoTrack? stretch = _behaviour.bodyScaleY;
    final double cycle = _cycle(KairoIdleMotion.breathPeriod);
    final double scaleY = stretch != null
        ? stretch.at(_action)
        : KairoIdleMotion.breathScaleY.at(cycle);
    final double lift = stretch != null
        ? 0
        : KairoIdleMotion.breathShiftY.at(cycle);

    return Transform.scale(
      scaleY: scaleY,
      alignment: KairoPivots.alignment(KairoPivots.breath),
      child: lift == 0
          ? child
          : Transform.translate(
              offset: Offset(0, lift * _unit),
              child: child,
            ),
    );
  }

  /// The limbs, the torso and the head, in the order they overlap.
  Widget _parts() {
    final _RigLayers layers = _layers;
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: switch (widget.view) {
        KairoView.front || KairoView.threeQuarter => <Widget>[
          _joint(KairoJoint.legLeft, layers.legLeft),
          _joint(KairoJoint.legRight, layers.legRight),
          layers.torso,
          if (!_leftArmRaised) _joint(KairoJoint.armLeft, layers.armLeft),
          if (!_rightArmRaised) _joint(KairoJoint.armRight, layers.armRight),
          if (layers.heldProp != null) layers.heldProp!,
          _head(),
          if (_leftArmRaised) _joint(KairoJoint.armLeft, layers.armLeft),
          if (_rightArmRaised) _joint(KairoJoint.armRight, layers.armRight),
        ],
        KairoView.side => <Widget>[
          _joint(KairoJoint.legLeft, layers.legLeft),
          _joint(KairoJoint.armLeft, layers.armLeft),
          layers.torso,
          _joint(KairoJoint.legRight, layers.legRight),
          _joint(KairoJoint.armRight, layers.armRight),
          _head(),
        ],
        KairoView.back => <Widget>[
          _joint(KairoJoint.legLeft, layers.legLeft),
          _joint(KairoJoint.legRight, layers.legRight),
          layers.torso,
          _joint(KairoJoint.armLeft, layers.armLeft),
          _joint(KairoJoint.armRight, layers.armRight),
          _head(),
        ],
      },
    );
  }

  /// Whether the left arm passes in front of the body rather than behind it.
  ///
  /// An arm raised above shoulder height crosses the torso and the head, so it
  /// has to be drawn after them. Below that height it belongs behind.
  bool get _leftArmRaised =>
      _angles.armLeft.abs() > 60 || _behaviour.raisesLeftArm;

  /// Whether the right arm passes in front of the body rather than behind it.
  bool get _rightArmRaised =>
      _angles.armRight.abs() > 60 || _behaviour.raisesRightArm;

  /// One layer, turned to wherever its joint currently is.
  Widget _joint(KairoJoint joint, Widget child) {
    final double angle = _angleOf(joint);
    if (angle == 0) {
      return child;
    }
    return Transform.rotate(
      angle: _radians(angle),
      alignment: KairoPivots.alignment(KairoPivots.of(joint, widget.view)),
      child: child,
    );
  }

  /// Where [joint] currently is, in degrees.
  ///
  /// An animation driving a joint holds it outright; the pose covers the rest.
  /// The side view draws a near and a far limb rather than a left and a right,
  /// and only the two gaits are wired through to them.
  double _angleOf(KairoJoint joint) {
    final KairoTrack? track = _behaviour.trackFor(joint);
    final bool profileLimb =
        widget.view == KairoView.side && joint != KairoJoint.head;

    double angle;
    if (track != null && (!profileLimb || _behaviour.movesSideLimbs)) {
      angle = track.at(_action);
    } else if (_facing) {
      angle = _angles.angleOf(joint);
    } else {
      angle = 0;
    }

    if (joint == KairoJoint.head) {
      angle += _headTurn;
    }
    return angle;
  }

  /// How far the head turns to follow [KairoCharacter.lookAt].
  ///
  /// An animation already turning the head keeps it: nothing should fight the
  /// character for its own neck.
  double get _headTurn {
    final Offset? target = widget.lookAt;
    if (target == null || _behaviour.head != null) {
      return 0;
    }
    return target.dx.clamp(-1.0, 1.0) * 4;
  }

  // ----------------------------------------------------------------- head --

  Widget _head() {
    final _RigLayers layers = _layers;
    Widget head = Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: <Widget>[
        layers.head,
        if (layers.eyes != null) _faceLayer(layers),
        ..._extras(),
      ],
    );

    // The three-quarter view is the front view turned, not redrawn: the head
    // narrows very slightly and slides across.
    if (widget.view == KairoView.threeQuarter) {
      head = Transform.scale(
        scaleX: 0.98,
        alignment: KairoPivots.alignment(const Offset(100, 80)),
        child: Transform.translate(
          offset: Offset(-3 * _unit, 0),
          child: head,
        ),
      );
    }

    return _joint(KairoJoint.head, head);
  }

  /// The brows, eyes, nose, mouth and blush, which slide together when the head
  /// turns away from the viewer.
  Widget _faceLayer(_RigLayers layers) {
    Widget face = Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: <Widget>[
        if (layers.brows != null) layers.brows!,
        _eyes(layers.eyes!),
        if (layers.nose != null) layers.nose!,
        if (layers.mouth != null) _mouth(layers.mouth!),
        if (layers.blush != null) layers.blush!,
      ],
    );

    if (widget.view == KairoView.threeQuarter) {
      face = Transform.translate(
        offset: Offset(-7 * _unit, 0),
        child: face,
      );
    }
    return face;
  }

  /// The eyes: blinking, following the pose, and looking where they are told.
  Widget _eyes(Widget child) {
    Widget eyes = child;

    if (_behaviour.blinks) {
      eyes = Transform.scale(
        scaleY: KairoIdleMotion.blinkScaleY.at(
          _cycle(KairoIdleMotion.blinkPeriod),
        ),
        alignment: KairoPivots.alignment(KairoPivots.eyes),
        child: eyes,
      );
    }

    final Offset? target = widget.lookAt;
    final double shiftX =
        (_behaviour.eyeShiftX?.at(_action) ?? 0) +
        (target == null ? 0 : target.dx.clamp(-1.0, 1.0) * 3);
    final double shiftY =
        (_facing ? _angles.eyeShiftY : 0) +
        (target == null ? 0 : target.dy.clamp(-1.0, 1.0) * 2.5);

    if (shiftX == 0 && shiftY == 0) {
      return eyes;
    }
    return Transform.translate(
      offset: Offset(shiftX * _unit, shiftY * _unit),
      child: eyes,
    );
  }

  /// The mouth, which only moves while the character is speaking.
  Widget _mouth(Widget child) {
    final KairoTrack? talk = _behaviour.mouthScaleY;
    if (talk == null) {
      return child;
    }
    return Transform.scale(
      scaleY: talk.at(_action),
      alignment: KairoPivots.alignment(KairoPivots.mouth),
      child: child,
    );
  }

  /// The symbol floating beside the head, if the expression has one.
  List<Widget> _extras() =>
      _layers.extras.map(_extra).toList(growable: false);

  Widget _extra(_ExtraLayer layer) {
    final KairoExtraPiece piece = layer.piece;
    final double cycle =
        _cycle(KairoIdleMotion.periodOf(piece.motion)) - piece.delay;
    switch (piece.motion) {
      case KairoExtraMotion.drift:
        return Transform.translate(
          offset: Offset(0, KairoIdleMotion.driftShiftY.at(cycle) * _unit),
          child: layer.child,
        );
      case KairoExtraMotion.pulse:
        return Opacity(
          opacity: _opacity(KairoIdleMotion.pulseOpacity.at(cycle)),
          child: layer.child,
        );
      case KairoExtraMotion.rise:
        return Opacity(
          opacity: _opacity(KairoIdleMotion.riseOpacity.at(cycle)),
          child: Transform.translate(
            offset: Offset(
              KairoIdleMotion.riseShiftX.at(cycle) * _unit,
              KairoIdleMotion.riseShiftY.at(cycle) * _unit,
            ),
            child: layer.child,
          ),
        );
      case KairoExtraMotion.twinkle:
        return Opacity(
          opacity: _opacity(KairoIdleMotion.twinkleOpacity.at(cycle)),
          child: Transform.scale(
            scale: KairoIdleMotion.twinkleScale.at(cycle),
            alignment: KairoPivots.alignment(piece.pivot),
            child: layer.child,
          ),
        );
    }
  }

  /// The confetti, falling and spinning, each piece on its own schedule.
  List<Widget> _confetti() {
    final double cycle = _cycle(KairoIdleMotion.confettiPeriod);
    return _confettiLayers.map((_ConfettiLayer layer) {
      final double at = cycle - layer.piece.delay;
      return Opacity(
        opacity: _opacity(KairoIdleMotion.confettiOpacity.at(at)),
        child: Transform.translate(
          offset: Offset(0, KairoIdleMotion.confettiShiftY.at(at) * _unit),
          child: Transform.rotate(
            angle: _radians(KairoIdleMotion.confettiRotation.at(at)),
            alignment: KairoPivots.alignment(layer.piece.pivot),
            child: layer.child,
          ),
        ),
      );
    }).toList(growable: false);
  }

  // ----------------------------------------------------------- the layers --

  /// Draws every layer this view, expression and pose needs.
  ///
  /// Called when one of those changes, and never per frame: an animation moves
  /// the layers it is given, it does not ask for new ones.
  _RigLayers _buildLayers() {
    final KairoBodyParts body = KairoBodyParts(widget.hoodie);
    final KairoFace face = _face;

    final Widget? shadow = widget.hasShadow
        ? _draw(KairoBodyParts.groundShadow)
        : null;

    switch (widget.view) {
      case KairoView.front:
      case KairoView.threeQuarter:
        final KairoProp? prop = _angles.prop;
        final String bothHands = body.heldInBothHands(prop);
        return _RigLayers(
          shadow: shadow,
          legLeft: _draw(body.frontLegLeft),
          legRight: _draw(body.frontLegRight),
          torso: _draw(body.frontTorso),
          armLeft: _draw(body.frontArmLeft),
          armRight: _draw(body.frontArmRight(prop)),
          head: _draw(
            body.frontHead(
              threeQuarter: widget.view == KairoView.threeQuarter,
            ),
          ),
          brows: _draw(KairoFaceParts.brows(face.brow)),
          eyes: _draw(KairoFaceParts.eyes(face.eye), withIris: true),
          nose: _draw(KairoFaceParts.nose),
          mouth: _draw(KairoFaceParts.mouth(face.mouth)),
          blush: _draw(KairoFaceParts.blush(face.blush)),
          heldProp: bothHands.isEmpty ? null : _draw(bothHands),
          extras: face.extra == null
              ? const <_ExtraLayer>[]
              : KairoFaceParts.extras(face.extra!)
                    .map(
                      (KairoExtraPiece piece) =>
                          _ExtraLayer(_draw(piece.svg), piece),
                    )
                    .toList(growable: false),
        );
      case KairoView.side:
        return _RigLayers(
          shadow: shadow,
          legLeft: _draw(body.sideLegFar),
          legRight: _draw(body.sideLegNear),
          torso: _draw(body.sideTorso),
          armLeft: _draw(body.sideArmFar),
          armRight: _draw(body.sideArmNear),
          head: _draw(
            '${body.sideHead}${KairoFaceParts.sideFace}'
            '${KairoFaceParts.sideEye(face.eye)}',
            withIris: true,
          ),
        );
      case KairoView.back:
        return _RigLayers(
          shadow: shadow,
          legLeft: _draw(body.backLegLeft),
          legRight: _draw(body.backLegRight),
          torso: _draw(body.backTorso),
          armLeft: _draw(body.backArmLeft),
          armRight: _draw(body.backArmRight),
          head: _draw(body.backHead),
        );
    }
  }

  /// The confetti, which is the same eight pieces whatever else changes.
  static final List<_ConfettiLayer> _confettiLayers = KairoBodyParts.confetti
      .map(
        (KairoConfettiPiece piece) => _ConfettiLayer(_draw(piece.svg), piece),
      )
      .toList(growable: false);

  /// Wraps one layer's shapes in a document of its own and draws it.
  ///
  /// Every layer carries the whole rig's view box, so stacking them reassembles
  /// the character with no arithmetic. Each is a standalone document, which is
  /// why a layer drawing an eye must bring the iris gradient with it.
  static Widget _draw(String shapes, {bool withIris = false}) =>
      SvgPicture.string(
        '<svg xmlns="http://www.w3.org/2000/svg" '
        'viewBox="0 0 ${KairoPivots.width} ${KairoPivots.height}">'
        '${withIris ? KairoFaceParts.irisGradient : ''}$shapes</svg>',
        fit: BoxFit.fill,
        clipBehavior: Clip.none,
        allowDrawingOutsideViewBox: true,
      );

  static double _radians(double degrees) => degrees * math.pi / 180;

  static double _opacity(double value) => value.clamp(0.0, 1.0);
}

/// Every drawing the character currently needs, drawn once.
///
/// The side and back views have no face and no props, so those layers are
/// absent rather than empty.
class _RigLayers {
  const _RigLayers({
    required this.legLeft,
    required this.legRight,
    required this.torso,
    required this.armLeft,
    required this.armRight,
    required this.head,
    this.shadow,
    this.brows,
    this.eyes,
    this.nose,
    this.mouth,
    this.blush,
    this.heldProp,
    this.extras = const <_ExtraLayer>[],
  });

  final Widget? shadow;
  final Widget legLeft;
  final Widget legRight;
  final Widget torso;
  final Widget armLeft;
  final Widget armRight;
  final Widget head;

  final Widget? brows;
  final Widget? eyes;
  final Widget? nose;
  final Widget? mouth;
  final Widget? blush;

  /// A prop held level in both hands, which turns with neither arm.
  final Widget? heldProp;

  final List<_ExtraLayer> extras;
}

class _ExtraLayer {
  const _ExtraLayer(this.child, this.piece);

  final Widget child;
  final KairoExtraPiece piece;
}

class _ConfettiLayer {
  const _ConfettiLayer(this.child, this.piece);

  final Widget child;
  final KairoConfettiPiece piece;
}
