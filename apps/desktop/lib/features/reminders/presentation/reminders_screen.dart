import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kairo_design_system/design_system.dart';
import 'package:kairo_shared_models/shared_models.dart';
import 'package:kairo_storage/storage.dart';

import '../../../app/router.dart';
import '../application/reminder_providers.dart';
import 'reminder_visuals.dart';

/// Where the user decides what Kairo reminds them about, and how often.
///
/// Changes are written straight to storage. Nothing here tells the scheduler:
/// the reminder engine follows the same data and reschedules on the row change.
class RemindersScreen extends ConsumerWidget {
  /// Creates the reminders screen.
  const RemindersScreen({super.key});

  /// Keeps content readable when the window is stretched wide.
  static const double _maxWidth = 680;

  /// The intervals offered, in minutes. One minute is not a real setting — it
  /// is there so a new user can see what Kairo does without waiting.
  static const List<int> _intervalChoices = <int>[
    1,
    5,
    10,
    15,
    20,
    30,
    45,
    60,
    90,
    120,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ReminderDefinition>> definitions =
        ref.watch(reminderDefinitionsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(KairoRoutes.dashboard),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        title: const Text('Reminders'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: switch (definitions) {
            AsyncData<List<ReminderDefinition>>(:final List<ReminderDefinition> value) =>
              ListView.separated(
                padding: const EdgeInsets.all(KairoSpacing.xl),
                itemCount: value.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: KairoSpacing.sm),
                itemBuilder: (_, int index) => _ReminderSettingsRow(
                  definition: value[index],
                  intervalChoices: _intervalChoices,
                ),
              ),
            AsyncError<List<ReminderDefinition>>() => const Center(
                child: Text('Your reminders could not be read.'),
              ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }
}

/// One reminder's switch and interval.
class _ReminderSettingsRow extends ConsumerWidget {
  const _ReminderSettingsRow({
    required this.definition,
    required this.intervalChoices,
  });

  final ReminderDefinition definition;
  final List<int> intervalChoices;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ReminderRepository reminders =
        ref.watch(reminderRepositoryProvider);

    // The saved interval may predate a change to the list above. It is added
    // back rather than snapped to a nearby choice, and a DropdownButton whose
    // value is absent from its items throws.
    final int currentMinutes = definition.interval.inMinutes;
    final List<int> choices = <int>[...intervalChoices];
    if (!choices.contains(currentMinutes)) {
      choices
        ..add(currentMinutes)
        ..sort();
    }

    return KairoCard(
      padding: const EdgeInsets.symmetric(
        horizontal: KairoSpacing.lg,
        vertical: KairoSpacing.md,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            iconForKind(definition.kind),
            color: definition.enabled
                ? KairoColors.primary
                : KairoColors.textTertiary,
          ),
          const SizedBox(width: KairoSpacing.md),
          Expanded(
            child: Text(definition.label, style: textTheme.bodyLarge),
          ),
          const SizedBox(width: KairoSpacing.md),
          DropdownButton<int>(
            value: currentMinutes,
            underline: const SizedBox.shrink(),
            borderRadius: KairoRadius.cardBorderRadius,
            onChanged: definition.enabled
                ? (int? minutes) {
                    if (minutes != null) {
                      reminders.upsertDefinition(
                        definition.copyWith(
                          interval: Duration(minutes: minutes),
                        ),
                      );
                    }
                  }
                : null,
            items: choices
                .map(
                  (int minutes) => DropdownMenuItem<int>(
                    value: minutes,
                    child: Text(describeInterval(Duration(minutes: minutes))),
                  ),
                )
                .toList(),
          ),
          const SizedBox(width: KairoSpacing.sm),
          Switch(
            value: definition.enabled,
            onChanged: (bool enabled) => reminders.upsertDefinition(
              definition.copyWith(enabled: enabled),
            ),
          ),
        ],
      ),
    );
  }
}
