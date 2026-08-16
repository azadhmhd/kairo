import 'dart:convert';

import 'package:kairo_shared_models/shared_models.dart';

/// The wire format between the main isolate and the character window.
///
/// The two are separate Dart programs sharing no memory, so everything between
/// them is text on a platform channel. Both ends encode and decode here, which
/// is what stops them drifting apart.
sealed class CharacterMessage {
  const CharacterMessage();

  /// Reads a message, or returns null if [text] is not one.
  ///
  /// Null rather than throwing: this is a boundary between two programs, and a
  /// message from a newer version should be ignored, not surfaced as a crash.
  static CharacterMessage? decode(String text) {
    final Object? decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final Object? type = decoded['type'];
    switch (type) {
      case ShowReminder._type:
        final Object? id = decoded['id'];
        final Object? label = decoded['label'];
        if (id is! String || label is! String) {
          return null;
        }
        return ShowReminder(
          occurrenceId: id,
          label: label,
          reactions: _reactionsFrom(decoded['reactions']),
        );

      case ReminderUnanswered._type:
        return const ReminderUnanswered();

      case SayLine._type:
        final Object? line = decoded['line'];
        return line is String ? SayLine(line) : null;

      case ReminderSettled._type:
        final ReminderOutcome? outcome = _outcomeNamed(decoded['outcome']);
        if (outcome == null) {
          return null;
        }
        return ReminderSettled(outcome);

      case AnswerReminder._type:
        final Object? id = decoded['id'];
        final ReminderOutcome? outcome = _outcomeNamed(decoded['outcome']);
        if (id is! String || outcome == null) {
          return null;
        }
        return AnswerReminder(occurrenceId: id, outcome: outcome);

      default:
        return null;
    }
  }

  /// Writes this message as the text the relay carries.
  String encode();

  static Map<ReminderOutcome, String> _reactionsFrom(Object? decoded) {
    if (decoded is! Map<String, dynamic>) {
      return const <ReminderOutcome, String>{};
    }
    return <ReminderOutcome, String>{
      for (final MapEntry<String, dynamic> entry in decoded.entries)
        if (_outcomeNamed(entry.key) case final ReminderOutcome outcome)
          if (entry.value is String) outcome: entry.value as String,
    };
  }

  static ReminderOutcome? _outcomeNamed(Object? name) {
    for (final ReminderOutcome outcome in ReminderOutcome.values) {
      if (outcome.name == name) {
        return outcome;
      }
    }
    return null;
  }
}

/// A reminder has come due, and Kairo should deliver it.
///
/// Carries the wording rather than an id: the character window has no database
/// to look one up in.
final class ShowReminder extends CharacterMessage {
  /// Announces the reminder [label], recorded as occurrence [occurrenceId].
  const ShowReminder({
    required this.occurrenceId,
    required this.label,
    this.reactions = const <ReminderOutcome, String>{},
  });

  static const String _type = 'show';

  /// The firing this is about, quoted back with the user's answer.
  final String occurrenceId;

  /// What Kairo should say.
  final String label;

  /// What to say on the way out for each answer, sent ahead of the click so
  /// the character can react without waiting for a round trip.
  final Map<ReminderOutcome, String> reactions;

  @override
  String encode() => jsonEncode(<String, Object?>{
    'type': _type,
    'id': occurrenceId,
    'label': label,
    'reactions': <String, String>{
      for (final MapEntry<ReminderOutcome, String> entry in reactions.entries)
        entry.key.name: entry.value,
    },
  });
}

/// The reminder on screen has been answered, and this is what the user chose.
///
/// Sent for every answer, including ones the character reported itself, so the
/// character has one way to finish rather than one per button. The outcome
/// travels with it because the reaction depends on it.
final class ReminderSettled extends CharacterMessage {
  /// Announces that the reminder ended in [outcome].
  const ReminderSettled(this.outcome);

  static const String _type = 'settled';

  /// What the user chose.
  final ReminderOutcome outcome;

  @override
  String encode() => jsonEncode(<String, Object?>{
    'type': _type,
    'outcome': outcome.name,
  });
}

/// The reminder stood on the desktop long enough without an answer.
///
/// Not an outcome: nothing is decided or recorded. The occurrence stays
/// pending, the main window goes on showing it, and the next firing of the same
/// reminder marks it missed.
final class ReminderUnanswered extends CharacterMessage {
  /// Announces that nobody answered.
  const ReminderUnanswered();

  static const String _type = 'unanswered';

  @override
  String encode() => jsonEncode(<String, Object?>{'type': _type});
}

/// Something to say that is not a reminder and needs no answer.
final class SayLine extends CharacterMessage {
  /// Asks the character to say [line] and then leave.
  const SayLine(this.line);

  static const String _type = 'say';

  /// What to say.
  final String line;

  @override
  String encode() => jsonEncode(<String, Object?>{'type': _type, 'line': line});
}

/// The user answered the reminder from the character's own bubble.
final class AnswerReminder extends CharacterMessage {
  /// Reports [outcome] for the firing [occurrenceId].
  const AnswerReminder({required this.occurrenceId, required this.outcome});

  static const String _type = 'answer';

  /// Which firing was answered.
  final String occurrenceId;

  /// What the user chose. Only completed, snoozed and dismissed travel this
  /// way; pending and missed are Kairo's own bookkeeping.
  final ReminderOutcome outcome;

  @override
  String encode() => jsonEncode(<String, Object?>{
    'type': _type,
    'id': occurrenceId,
    'outcome': outcome.name,
  });
}
