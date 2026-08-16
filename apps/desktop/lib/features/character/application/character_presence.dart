import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:kairo_ai/ai.dart';
import 'package:kairo_desktop_engine/desktop_engine.dart';
import 'package:kairo_event_bus/event_bus.dart';
import 'package:kairo_reminder_engine/reminder_engine.dart';
import 'package:kairo_shared_models/shared_models.dart';
import 'package:kairo_storage/storage.dart';

import 'character_messages.dart';

/// Where the character window sits on [display], which is the usable area.
///
/// Flush with the right edge, on the floor. Flush deliberately: the character
/// walks in from off screen, and a gap would be a strip of desktop they appear
/// inside rather than walk in from.
Offset characterPositionOn(Rect display) {
  final Size window = KairoWindowDescriptor.characterWindow.size;
  return Offset(
    display.right - window.width,
    display.bottom - window.height,
  );
}

/// Keeps the character window in step with the rest of Kairo.
///
/// The window only draws — no event bus, no database. This watches the bus,
/// tells the window what to say, and turns clicks back into recorded answers.
///
/// Runs in the main isolate, where the truth is. The window's messages are
/// treated as reports of a click and nothing more: the occurrence they name is
/// looked up here, and an answer to a reminder no longer waiting is dropped.
class CharacterPresence {
  /// Creates the link between [channel] and the reminder [service].
  CharacterPresence({
    required KairoIsolateChannel channel,
    required KairoEventBus eventBus,
    required ReminderService service,
    required CoachRepository coach,
    required KairoDesktopEngine engine,
    required KairoNativeWindowController window,
  }) : _channel = channel,
       _eventBus = eventBus,
       _service = service,
       _coach = coach,
       _engine = engine,
       _window = window;

  final KairoIsolateChannel _channel;
  final KairoEventBus _eventBus;
  final ReminderService _service;
  final CoachRepository _coach;
  final KairoDesktopEngine _engine;
  final KairoNativeWindowController _window;

  final Random _random = Random();

  Map<ReminderOutcome, List<String>> _reactions =
      const <ReminderOutcome, List<String>>{};

  /// How long the character waits on screen for an answer.
  static const Duration patience = Duration(seconds: 30);

  StreamSubscription<ReminderDueEvent>? _due;
  StreamSubscription<ReminderAnsweredEvent>? _answered;
  StreamSubscription<CoachSpokeEvent>? _spoke;
  StreamSubscription<Map<ReminderOutcome, List<String>>>? _reactionsChanged;
  StreamSubscription<String>? _fromCharacter;

  /// The reminder being asked about. Held because the window reports only an
  /// id, and recording an answer needs the occurrence itself.
  ReminderOccurrence? _asking;

  /// Counts down [patience] for the reminder Kairo is currently asking about.
  Timer? _waiting;

  /// Starts following the bus and the character window.
  void start() {
    _due = _eventBus.on<ReminderDueEvent>().listen(
      (ReminderDueEvent event) =>
          _reporting('showing a reminder', () => _onDue(event)),
    );
    _answered = _eventBus.on<ReminderAnsweredEvent>().listen(
      (ReminderAnsweredEvent event) =>
          _reporting('taking a reminder away', () => _onAnswered(event)),
    );
    _spoke = _eventBus.on<CoachSpokeEvent>().listen(
      (CoachSpokeEvent event) =>
          _reporting('saying goodnight', () => _onSpoke(event)),
    );
    _reactionsChanged = _coach.watchReactions().listen(
      (Map<ReminderOutcome, List<String>> reactions) =>
          _reactions = reactions,
    );
    _fromCharacter = _channel.messages.listen(
      (String text) =>
          _reporting('recording an answer', () => _onCharacterMessage(text)),
    );
  }

  /// Runs [work], reporting anything it throws rather than losing it.
  ///
  /// These all run from stream listeners, where an exception is an unhandled
  /// async error that reaches nobody: the character would silently stop.
  Future<void> _reporting(String what, Future<void> Function() work) async {
    try {
      await work();
    } on Object catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'kairo character',
          context: ErrorDescription(what),
        ),
      );
    }
  }

  /// Stops following the bus and the window.
  Future<void> dispose() async {
    _waiting?.cancel();
    _waiting = null;
    await _due?.cancel();
    await _answered?.cancel();
    await _spoke?.cancel();
    await _reactionsChanged?.cancel();
    await _fromCharacter?.cancel();
    _due = null;
    _answered = null;
    _spoke = null;
    _reactionsChanged = null;
    _fromCharacter = null;
    _asking = null;
  }

  /// Sends the reminder to the character and makes the window clickable.
  ///
  /// It ignores the mouse the rest of the time so the desktop underneath keeps
  /// working.
  Future<void> _onDue(ReminderDueEvent event) async {
    _asking = event.occurrence;

    // Told first, placed second: the move needs a round trip to the platform to
    // learn the display bounds, and the character is still walking on when it
    // lands. Waiting for it would delay the reminder itself.
    await _channel.send(
      ShowReminder(
        occurrenceId: event.occurrence.id,
        label: event.definition.label,
        reactions: _reactionsNow(),
      ).encode(),
    );
    await _window.setIgnoresMouseEvents(ignore: false);

    // The timeout lives here, not in the character window: the same clock that
    // sends the character away has to be the one that lets clicks fall through
    // again, or the desktop stays blocked by a character who has gone.
    _waiting?.cancel();
    _waiting = Timer(patience, () => _reporting('giving up on a reminder', _giveUp));

    await _window.move(characterPositionOn(await _engine.activeDisplayBounds()));

    // Ordered forward on every arrival, not just the first: the user may have
    // changed desktop or entered a full screen space since the last one.
    await _window.show();
  }

  /// Tells the character how the reminder ended, however it was answered.
  ///
  /// Fires for answers given in the main window and for ones the character
  /// reported itself, since both reach the bus.
  ///
  /// Clicks start falling through immediately. The character stays on screen a
  /// moment longer for its parting line, but there is nothing left to click.
  Future<void> _onAnswered(ReminderAnsweredEvent event) async {
    if (_asking?.id != event.occurrence.id) {
      return;
    }
    _asking = null;
    _waiting?.cancel();
    await _channel.send(ReminderSettled(event.outcome).encode());
    await _window.setIgnoresMouseEvents(ignore: true);
  }

  /// One reaction per answer the user could give, drawn fresh each time so the
  /// same reminder twice running is not met with the same words.
  Map<ReminderOutcome, String> _reactionsNow() {
    return <ReminderOutcome, String>{
      for (final MapEntry<ReminderOutcome, List<String>> entry
          in _reactions.entries)
        if (entry.value.isNotEmpty)
          entry.key: entry.value[_random.nextInt(entry.value.length)],
    };
  }

  /// Brings the character on to say something that needs no answer. Skipped
  /// while a reminder is on screen, which is waiting for the user.
  Future<void> _onSpoke(CoachSpokeEvent event) async {
    if (_asking != null) {
      return;
    }

    await _channel.send(SayLine(event.line).encode());
    await _window.move(characterPositionOn(await _engine.activeDisplayBounds()));
    await _window.show();
  }

  /// Sends the character away after [patience] with no answer.
  ///
  /// The occurrence is left untouched: nothing was decided, so it stays pending
  /// and the next firing of the same reminder marks it missed.
  Future<void> _giveUp() async {
    if (_asking == null) {
      return;
    }
    _asking = null;
    await _channel.send(const ReminderUnanswered().encode());
    await _window.setIgnoresMouseEvents(ignore: true);
  }

  /// Records what the user clicked on the character.
  Future<void> _onCharacterMessage(String text) async {
    final CharacterMessage? message = CharacterMessage.decode(text);
    if (message is! AnswerReminder) {
      return;
    }

    final ReminderOccurrence? occurrence = _asking;
    if (occurrence == null || occurrence.id != message.occurrenceId) {
      // The reminder was answered elsewhere between the click and this
      // arriving. The first answer stands.
      return;
    }

    switch (message.outcome) {
      case ReminderOutcome.completed:
        await _service.complete(occurrence);
      case ReminderOutcome.snoozed:
        await _service.snooze(occurrence);
      case ReminderOutcome.dismissed:
        await _service.dismiss(occurrence);
      case ReminderOutcome.pending:
      case ReminderOutcome.missed:
        // Not answers a user can give; Kairo records these itself.
        break;
    }
  }
}
