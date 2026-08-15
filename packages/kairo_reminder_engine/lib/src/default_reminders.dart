import 'package:kairo_shared_models/shared_models.dart';

/// The reminders a new installation starts with.
///
/// Seeded once, then owned by the user. Kairo never restores one after it has
/// been edited or disabled.
///
/// The intervals follow the advice each reminder is about — twenty minutes for
/// the 20-20-20 rule, an hour for standing — and are starting points only.
const List<ReminderDefinition> defaultReminders = <ReminderDefinition>[
  ReminderDefinition(
    id: 'water',
    kind: ReminderKind.water,
    label: 'Time for a glass of water',
    interval: Duration(minutes: 45),
  ),
  ReminderDefinition(
    id: 'stand',
    kind: ReminderKind.stand,
    label: 'Stand up and stretch for a moment',
    interval: Duration(minutes: 60),
  ),
  ReminderDefinition(
    id: 'eyes',
    kind: ReminderKind.eyes,
    label: 'Look at something far away for twenty seconds',
    interval: Duration(minutes: 20),
  ),
];
