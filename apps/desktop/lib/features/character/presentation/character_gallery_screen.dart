import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kairo_character_engine/character_engine.dart';
import 'package:kairo_design_system/design_system.dart';

import '../../../app/router.dart';

/// Every view, expression, pose and animation the character rig can draw.
///
/// Development scaffolding, not a feature: nothing in the interface links here.
/// Its sections mirror `assets/rive/Kairo Character Sheet.dc.html` in order, so
/// the port can be checked by opening the sheet beside this window.
class CharacterGalleryScreen extends StatelessWidget {
  /// Creates the character gallery.
  const CharacterGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(KairoRoutes.dashboard),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        title: const Text('Character rig'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(KairoSpacing.xl),
        children: <Widget>[
          _Section(
            number: '02',
            title: 'Turnaround',
            caption: 'The same rig from four sides. The head is about 45% of '
                'the total height in every one of them.',
            child: _Grid(
              children: <Widget>[
                for (final KairoView view in KairoView.values)
                  _Cell(
                    label: _readable(view.name),
                    child: KairoCharacter(view: view, size: 150),
                  ),
              ],
            ),
          ),
          _Section(
            number: '03',
            title: 'Expressions',
            caption: 'Sixteen faces from four swappable layers: brows, eyes, '
                'mouth and the symbol beside the head. Blush is a fifth dial.',
            child: _Grid(
              children: <Widget>[
                for (final KairoExpression expression
                    in KairoExpression.values)
                  _Cell(
                    label: _readable(expression.name),
                    child: KairoCharacter(expression: expression, size: 110),
                  ),
              ],
            ),
          ),
          _Section(
            number: '04',
            title: 'Poses',
            caption: 'Nineteen poses, every one of them joint rotations on the '
                'same rig. Nothing here is redrawn.',
            child: _Grid(
              children: <Widget>[
                for (final KairoPose pose in KairoPose.values)
                  _Cell(
                    label: _readable(pose.name),
                    child: KairoCharacter(
                      pose: pose,
                      expression: KairoExpression.happy,
                      size: 125,
                    ),
                  ),
              ],
            ),
          ),
          _Section(
            number: '05',
            title: 'Animation states',
            caption: 'Every loop running at once. Breathing and blinking run '
                'underneath all of them.',
            child: _Grid(
              children: <Widget>[
                for (final KairoAnimation animation in KairoAnimation.values)
                  _Cell(
                    label: _readable(animation.name),
                    child: KairoCharacter(
                      animation: animation,
                      pose: _poseFor(animation),
                      expression: _expressionFor(animation),
                      size: 140,
                    ),
                  ),
              ],
            ),
          ),
          _Section(
            number: '06',
            title: 'Walk cycle',
            caption: 'One 0.74 second cycle, frozen at eight even moments. The '
                'arms counter-swing the legs and the body bobs twice per '
                'cycle.',
            child: _Grid(
              children: <Widget>[
                for (int frame = 0; frame < 8; frame++)
                  _Cell(
                    label: '${frame + 1}',
                    child: KairoCharacter(
                      view: KairoView.side,
                      animation: KairoAnimation.walk,
                      size: 110,
                      paused: true,
                      phase: frame / 8,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The pose each animation is shown in, matching the character sheet. An
  /// animation drives its own joints, so this only sets the ones it leaves.
  static KairoPose _poseFor(KairoAnimation animation) => switch (animation) {
    KairoAnimation.walk => KairoPose.walking,
    KairoAnimation.run => KairoPose.running,
    KairoAnimation.wave => KairoPose.waving,
    KairoAnimation.think => KairoPose.thinking,
    KairoAnimation.sleep => KairoPose.sleeping,
    KairoAnimation.drink => KairoPose.holdingWater,
    KairoAnimation.celebrate => KairoPose.celebrating,
    KairoAnimation.stretch => KairoPose.stretching,
    _ => KairoPose.standing,
  };

  static KairoExpression _expressionFor(KairoAnimation animation) =>
      switch (animation) {
        KairoAnimation.sleep => KairoExpression.sleeping,
        KairoAnimation.think => KairoExpression.thinking,
        KairoAnimation.celebrate => KairoExpression.celebrating,
        KairoAnimation.talk => KairoExpression.encouraging,
        KairoAnimation.look => KairoExpression.curious,
        _ => KairoExpression.happy,
      };

  /// Turns an enum's name into something a person would read.
  static String _readable(String name) {
    final String spaced = name.replaceAllMapped(
      RegExp('[A-Z]'),
      (Match match) => ' ${match[0]!.toLowerCase()}',
    );
    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.number,
    required this.title,
    required this.caption,
    required this.child,
  });

  final String number;
  final String title;
  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: KairoSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$number · $title',
            style: textTheme.titleSmall?.copyWith(color: KairoColors.primary),
          ),
          const SizedBox(height: KairoSpacing.xxs),
          Text(
            caption,
            style: textTheme.bodySmall?.copyWith(
              color: KairoColors.textSecondary,
            ),
          ),
          const SizedBox(height: KairoSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: KairoSpacing.md,
      runSpacing: KairoSpacing.md,
      children: children,
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return KairoCard(
      padding: const EdgeInsets.all(KairoSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          child,
          const SizedBox(height: KairoSpacing.xs),
          Text(label, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
