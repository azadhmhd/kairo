import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo_design_system/design_system.dart';
import 'package:kairo_reminder_engine/reminder_engine.dart';

import '../../settings/application/settings_controller.dart';
import '../application/reminder_providers.dart';
import 'reminder_visuals.dart';

/// The reminder currently asking for an answer, shown in the main window.
class ReminderBanner extends ConsumerWidget {
  /// Creates the banner.
  const ReminderBanner({super.key});

  static const double _maxWidth = 560;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only on arrival. Answering a reminder also pushes a value through this
    // provider, and that one is silent.
    ref.listen<AsyncValue<ReminderDueEvent?>>(
      currentReminderProvider,
      (AsyncValue<ReminderDueEvent?>? _, AsyncValue<ReminderDueEvent?> next) {
        final bool wanted =
            ref.read(settingsProvider).valueOrNull?.soundEnabled ?? true;
        if (next.valueOrNull != null && wanted) {
          // The platform's own alert sound: Kairo ships no audio, and this
          // respects whatever the user has already muted.
          SystemSound.play(SystemSoundType.alert);
        }
      },
    );

    final ReminderDueEvent? reminder =
        ref.watch(currentReminderProvider).valueOrNull;

    return AnimatedSwitcher(
      duration: PrimitiveDuration.normal,
      child: reminder == null
          ? const SizedBox.shrink()
          : _Banner(key: ValueKey<String>(reminder.occurrence.id), reminder: reminder),
    );
  }
}

class _Banner extends ConsumerWidget {
  const _Banner({required this.reminder, super.key});

  final ReminderDueEvent reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ReminderService service = ref.watch(reminderServiceProvider);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: ReminderBanner._maxWidth),
      child: KairoCard(
        child: Row(
          children: <Widget>[
            Icon(
              iconForKind(reminder.definition.kind),
              color: KairoColors.primary,
              size: PrimitiveIconSize.xl,
            ),
            const SizedBox(width: KairoSpacing.md),
            Expanded(
              child: Text(
                reminder.definition.label,
                style: textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: KairoSpacing.md),
            TextButton(
              onPressed: () => service.dismiss(reminder.occurrence),
              child: const Text('Not now'),
            ),
            const SizedBox(width: KairoSpacing.xs),
            TextButton(
              onPressed: () => service.snooze(reminder.occurrence),
              child: const Text('Snooze'),
            ),
            const SizedBox(width: KairoSpacing.xs),
            FilledButton(
              onPressed: () => service.complete(reminder.occurrence),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
