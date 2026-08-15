import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kairo_design_system/design_system.dart';
import 'package:kairo_scheduler/scheduler.dart';
import 'package:kairo_shared_models/shared_models.dart';

import '../../../app/router.dart';
import '../../reminders/application/reminder_providers.dart';
import '../../reminders/presentation/reminder_banner.dart';
import '../../reminders/presentation/reminder_visuals.dart';

/// How today is going, and what is coming next. Presentation only: every
/// number comes from a provider.
class DashboardScreen extends ConsumerWidget {
  /// Creates the dashboard.
  const DashboardScreen({super.key});

  /// Keeps content readable when the window is stretched wide.
  static const double _maxWidth = 680;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ReminderDefinition>> definitions =
        ref.watch(reminderDefinitionsProvider);
    final List<Widget> reminderRows = definitions.hasError
        ? <Widget>[
            Text(
              'Your reminders could not be read.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: KairoColors.error),
            ),
          ]
        : <Widget>[
            for (final ReminderDefinition definition
                in definitions.valueOrNull ?? const <ReminderDefinition>[])
              Padding(
                padding: const EdgeInsets.only(bottom: KairoSpacing.sm),
                child: _ReminderRow(definition: definition),
              ),
          ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kairo'),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.go(KairoRoutes.reports),
            icon: const Icon(Icons.insights_outlined),
            tooltip: 'Reports',
          ),
          IconButton(
            onPressed: () => context.go(KairoRoutes.reminders),
            icon: const Icon(Icons.tune),
            tooltip: 'Reminders',
          ),
          IconButton(
            onPressed: () => context.go(KairoRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
          ),
          const SizedBox(width: KairoSpacing.sm),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  KairoSpacing.xl,
                  KairoSpacing.md,
                  KairoSpacing.xl,
                  // Room for the banner to sit over the list without hiding
                  // the last reminder behind it.
                  KairoSpacing.huge * 2,
                ),
                children: <Widget>[
                  const _TodaySummary(),
                  const SizedBox(height: KairoSpacing.lg),
                  Text(
                    'Your reminders',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: KairoSpacing.sm),
                  ...reminderRows,
                ],
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(KairoSpacing.xl),
              child: ReminderBanner(),
            ),
          ),
        ],
      ),
    );
  }
}

/// How many reminders the user has finished today.
class _TodaySummary extends ConsumerWidget {
  const _TodaySummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int completed = ref.watch(completedTodayProvider);
    final int total = ref
            .watch(todaysOccurrencesProvider)
            .valueOrNull
            ?.length ??
        0;

    return KairoCard(
      padding: const EdgeInsets.all(KairoSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Today', style: textTheme.titleSmall),
          const SizedBox(height: KairoSpacing.xs),
          Text('$completed looked after', style: textTheme.displaySmall),
          const SizedBox(height: KairoSpacing.xxs),
          Text(
            switch (total) {
              0 => 'Nothing has come up yet. Kairo is watching the clock.',
              _ when completed == total =>
                'Everything Kairo asked for. Nicely done.',
              _ => 'out of $total Kairo asked about',
            },
            style: textTheme.bodyMedium?.copyWith(
              color: KairoColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// One reminder, and when it is next expected.
class _ReminderRow extends ConsumerWidget {
  const _ReminderRow({required this.definition});

  final ReminderDefinition definition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Watched so the countdown moves. The due time comes from the scheduler,
    // which is the only thing that knows when a reminder is genuinely next due.
    final DateTime now = ref.watch(clockProvider).valueOrNull ?? DateTime.now();
    final DateTime? due = ref.watch(schedulerProvider).dueAt(definition.id);

    final String status = !definition.enabled
        ? 'Paused'
        : due == null
            ? describeInterval(definition.interval)
            : '${describeTimeUntil(due, now)} · '
                '${describeInterval(definition.interval)}';

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(definition.label, style: textTheme.bodyLarge),
                const SizedBox(height: KairoSpacing.xxs),
                Text(
                  status,
                  style: textTheme.bodySmall?.copyWith(
                    color: KairoColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
