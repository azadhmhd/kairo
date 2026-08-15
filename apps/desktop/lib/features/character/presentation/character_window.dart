import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kairo_character_engine/character_engine.dart';
import 'package:kairo_design_system/design_system.dart';
import 'package:kairo_desktop_engine/desktop_engine.dart';
import 'package:kairo_shared_models/shared_models.dart';

import '../../../app/theme.dart';
import '../application/character_messages.dart';

/// What the character window draws.
///
/// Open for as long as Kairo runs and empty for nearly all of it. When the main
/// isolate says a reminder is due, the character walks in from off the right of
/// the screen, says it, and walks off once it has been answered.
///
/// The window is transparent, floats above other applications and lets clicks
/// fall through, so **nothing here may paint an opaque rectangle across the
/// whole surface** — a ground shadow included, since there is no floor.
///
/// Runs in its own isolate: no event bus, no database, no providers, and it
/// must not reach for any. Everything it knows arrives on
/// [KairoIsolateChannel]. It decides nothing.
class CharacterWindow extends StatelessWidget {
  /// Creates the character window's content.
  const CharacterWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: kairoTheme,
      // Transparent all the way down; an opaque colour here would paint the
      // rectangle the window is trying not to look like.
      color: const Color(0x00000000),
      home: const Scaffold(
        backgroundColor: Color(0x00000000),
        body: _Kairo(),
      ),
    );
  }
}

/// The character: arriving, saying its piece, and leaving.
class _Kairo extends StatefulWidget {
  const _Kairo();

  @override
  State<_Kairo> createState() => _KairoState();
}

class _KairoState extends State<_Kairo> with SingleTickerProviderStateMixin {
  /// How long the character takes to walk on.
  static const Duration _entranceDuration = Duration(milliseconds: 1600);

  /// How wide the character is drawn, in logical pixels.
  static const double _characterSize = 180;

  /// The space between the character and the right edge of the screen.
  static const double _edgeMargin = 24;

  /// How long the parting line stays up before the character walks off.
  static const Duration _farewellDuration = Duration(milliseconds: 1900);

  late final KairoIsolateChannel _channel;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _entranceDuration,
  );

  /// The walk on, easing out so the last step settles rather than stops dead.
  ///
  /// One whole box width to the right is off screen: the box is the character
  /// plus its edge margin, and the window sits flush with the display edge.
  late final Animation<Offset> _entrance =
      Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutSine),
      );

  /// What the character is asking about, or null when there is nothing.
  ShowReminder? _saying;

  /// The reaction being left on, or null when the character is not leaving.
  _Farewell? _farewell;

  /// Counts down the parting line.
  Timer? _parting;

  /// Whether the character is on screen, having finished walking on.
  bool get _present => _controller.status == AnimationStatus.completed;

  /// Whether the character is walking in rather than out. Decides facing: the
  /// rig's profile faces right, so walking in from the right edge mirrors it.
  bool get _walkingOn => _controller.status == AnimationStatus.forward;

  /// Keeps this isolate producing frames.
  ///
  /// Flutter stops rendering for an application it believes is hidden, and this
  /// engine drives a panel that deliberately refuses focus, so nothing ever
  /// tells it otherwise. With frames off, `scheduleFrame` does nothing, every
  /// [Ticker] waits forever, and the walk-on never starts — which keeps the
  /// window empty, which is what convinced the engine it was hidden.
  ///
  /// This window is on screen as long as the application runs, so from here the
  /// application is always resumed. Reasserted on every message.
  void _keepDrawing() {
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );
  }

  @override
  void initState() {
    super.initState();
    _keepDrawing();
    _channel = KairoIsolateChannel();
    _channel.messages.listen(_onMessage);

    // Not started: the character stays off screen until a reminder arrives.
    _controller.addStatusListener(_onWalkChanged);
  }

  @override
  void dispose() {
    _parting?.cancel();
    _controller.dispose();
    unawaited(_channel.dispose());
    super.dispose();
  }

  /// Rebuilds when the walk starts or stops.
  ///
  /// Status changes only at the ends of the walk, so this fires four times per
  /// visit rather than once per frame.
  void _onWalkChanged(AnimationStatus _) {
    if (mounted) {
      setState(() {});
    }
  }

  void _onMessage(String text) {
    final CharacterMessage? message = CharacterMessage.decode(text);
    if (!mounted) {
      return;
    }
    _keepDrawing();
    switch (message) {
      case final ShowReminder show:
        _ask(show);
      case final ReminderSettled settled:
        _part(settled.outcome);
      case ReminderUnanswered():
        // Nothing was chosen, so there is nothing to react to: leave silently.
        _leave();
      // The window sends these; it is never told them.
      case AnswerReminder():
      case null:
        break;
    }
  }

  /// Walks on, if not already here, and asks.
  void _ask(ShowReminder show) {
    _parting?.cancel();
    setState(() {
      _farewell = null;
      _saying = show;
    });
    _controller.forward();
  }

  /// Reports the user's answer, and reacts without waiting to be told to.
  ///
  /// The answer comes back as a [ReminderSettled] once the main isolate has
  /// recorded it, but reacting only then would lag a full round trip.
  void _answer(ReminderOutcome outcome) {
    final ShowReminder? saying = _saying;
    if (saying == null) {
      return;
    }
    _part(outcome);
    unawaited(
      _channel.send(
        AnswerReminder(
          occurrenceId: saying.occurrenceId,
          outcome: outcome,
        ).encode(),
      ),
    );
  }

  /// Says one last thing about [outcome], then walks back off.
  ///
  /// Runs once. An answer given here returns as a [ReminderSettled] a moment
  /// later, and reacting again would restart the goodbye. Does nothing when the
  /// character is off screen and so never delivered the reminder.
  void _part(ReminderOutcome outcome) {
    if (_farewell != null || _controller.isDismissed) {
      return;
    }
    setState(() {
      _saying = null;
      _farewell = _Farewell.forOutcome(outcome);
    });
    _parting?.cancel();
    _parting = Timer(_farewellDuration, _leave);
  }

  /// Walks back off the way it came.
  void _leave() {
    if (!mounted) {
      return;
    }
    setState(() {
      _saying = null;
      _farewell = null;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final ShowReminder? saying = _saying;
    final _Farewell? farewell = _farewell;

    final Widget bubble;
    if (farewell != null) {
      bubble = _SpeechBubble(
        key: const ValueKey<String>('farewell'),
        label: farewell.line,
      );
    } else if (saying != null && _present) {
      bubble = _SpeechBubble(
        key: ValueKey<String>(saying.occurrenceId),
        label: saying.label,
        onAnswer: _answer,
      );
    } else {
      bubble = const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: AnimatedSwitcher(
              duration: PrimitiveDuration.normal,
              child: bubble,
            ),
          ),
        ),
        SlideTransition(
          position: _entrance,
          child: SizedBox(
            width: _characterSize + _edgeMargin,
            child: Align(
              alignment: Alignment.centerLeft,
              child: KairoCharacter(
                // Walking is seen in profile, standing and talking face on.
                view: _present ? KairoView.front : KairoView.side,
                flipped: _walkingOn,
                animation: !_present
                    ? KairoAnimation.walk
                    : farewell?.animation ??
                          (saying == null
                              ? KairoAnimation.idle
                              : KairoAnimation.talk),
                expression: farewell?.expression ?? KairoExpression.happy,
                size: _characterSize,
                hasShadow: false,
                // Off screen, so nothing to animate. The rig repaints every
                // frame it moves in, and this window is empty most of the time.
                paused: _controller.isDismissed,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// How the character answers each outcome on the way out.
///
/// One line and one movement each. Kairo is never reproachful, and never
/// congratulates the user for an answer that was not a completion.
@immutable
class _Farewell {
  const _Farewell({
    required this.line,
    required this.animation,
    required this.expression,
  });

  /// What the character says about [outcome].
  factory _Farewell.forOutcome(ReminderOutcome outcome) => switch (outcome) {
    ReminderOutcome.completed => const _Farewell(
      line: 'Nice one.',
      animation: KairoAnimation.celebrate,
      expression: KairoExpression.celebrating,
    ),
    ReminderOutcome.snoozed => const _Farewell(
      line: "Alright — I'll ask again shortly.",
      animation: KairoAnimation.think,
      expression: KairoExpression.thinking,
    ),
    ReminderOutcome.dismissed => const _Farewell(
      line: 'No problem. Next time.',
      animation: KairoAnimation.wave,
      expression: KairoExpression.encouraging,
    ),
    // Bookkeeping outcomes, not buttons. Unreachable in practice; a plain
    // goodbye is the safe answer if one ever arrives.
    ReminderOutcome.pending || ReminderOutcome.missed => const _Farewell(
      line: 'See you soon.',
      animation: KairoAnimation.wave,
      expression: KairoExpression.happy,
    ),
  };

  /// The parting line.
  final String line;

  /// What the character does while saying it.
  final KairoAnimation animation;

  /// The face they say it with.
  final KairoExpression expression;
}

/// What the character is saying, and what the user can do about it.
///
/// The same three answers as the banner in the main window, in the same order
/// and wording — it is one reminder, and the surface should not change the
/// choices. A bubble with no [onAnswer] is a goodbye, which needs no buttons.
class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.label, this.onAnswer, super.key});

  final String label;

  /// What the user may do about it, or null when there is nothing left to do.
  final void Function(ReminderOutcome outcome)? onAnswer;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final void Function(ReminderOutcome outcome)? answer = onAnswer;

    return KairoCard(
      padding: const EdgeInsets.all(KairoSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(label, style: textTheme.titleSmall),
          if (answer != null) ...<Widget>[
            const SizedBox(height: KairoSpacing.sm),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextButton(
                  onPressed: () => answer(ReminderOutcome.dismissed),
                  child: const Text('Not now'),
                ),
                const SizedBox(width: KairoSpacing.xs),
                TextButton(
                  onPressed: () => answer(ReminderOutcome.snoozed),
                  child: const Text('Snooze'),
                ),
                const SizedBox(width: KairoSpacing.xs),
                FilledButton(
                  onPressed: () => answer(ReminderOutcome.completed),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
