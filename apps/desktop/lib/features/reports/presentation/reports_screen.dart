import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kairo_design_system/design_system.dart';
import 'package:kairo_shared_models/shared_models.dart';

import '../../../app/router.dart';
import '../../reminders/presentation/reminder_visuals.dart';
import '../application/report_providers.dart';

/// How the last week or month has gone.
///
/// Presentation only. The chart is ordinary widgets rather than a charting
/// library: a handful of proportional rectangles is not worth a dependency.
class ReportsScreen extends ConsumerWidget {
  /// Creates the reports screen.
  const ReportsScreen({super.key});

  /// Keeps content readable when the window is stretched wide.
  static const double _maxWidth = 680;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int range = ref.watch(reportRangeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(KairoRoutes.dashboard),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        title: const Text('Reports'),
        actions: <Widget>[
          SegmentedButton<int>(
            segments: const <ButtonSegment<int>>[
              ButtonSegment<int>(value: 7, label: Text('7 days')),
              ButtonSegment<int>(value: 30, label: Text('30 days')),
            ],
            selected: <int>{range},
            showSelectedIcon: false,
            onSelectionChanged: (Set<int> selection) =>
                ref.read(reportRangeProvider.notifier).state = selection.first,
          ),
          const SizedBox(width: KairoSpacing.lg),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: ListView(
            padding: const EdgeInsets.all(KairoSpacing.xl),
            children: const <Widget>[
              _StreakCard(),
              SizedBox(height: KairoSpacing.lg),
              _CompletionChart(),
              SizedBox(height: KairoSpacing.lg),
              _KindBreakdown(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The run of days the user has kept going.
class _StreakCard extends ConsumerWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int streak = ref.watch(streakProvider);
    final List<DailyTally> days = ref.watch(dailyTalliesFilledProvider);

    final int completed =
        days.fold(0, (int sum, DailyTally d) => sum + d.completed);
    final int due = days.fold(0, (int sum, DailyTally d) => sum + d.due);

    return KairoCard(
      padding: const EdgeInsets.all(KairoSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Current streak', style: textTheme.titleSmall),
                const SizedBox(height: KairoSpacing.xs),
                Text(
                  streak == 1 ? '1 day' : '$streak days',
                  style: textTheme.displaySmall,
                ),
                const SizedBox(height: KairoSpacing.xxs),
                Text(
                  streak == 0
                      ? 'Complete one reminder to start a new one.'
                      : 'Days in a row with at least one reminder done.',
                  style: textTheme.bodySmall?.copyWith(
                    color: KairoColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text('Completed', style: textTheme.titleSmall),
              const SizedBox(height: KairoSpacing.xs),
              Text('$completed of $due', style: textTheme.headlineSmall),
            ],
          ),
        ],
      ),
    );
  }
}

/// A bar per day, as tall as that day's completion rate.
class _CompletionChart extends ConsumerWidget {
  const _CompletionChart();

  static const double _height = 140;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<DailyTally> days = ref.watch(dailyTalliesFilledProvider);

    return KairoCard(
      padding: const EdgeInsets.all(KairoSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('How each day went', style: textTheme.titleSmall),
          const SizedBox(height: KairoSpacing.lg),
          SizedBox(
            height: _height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                for (final DailyTally day in days)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: KairoSpacing.xxs / 2,
                      ),
                      child: _Bar(day: day),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: KairoSpacing.sm),
          if (days.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  _shortDate(days.first.day),
                  style: textTheme.bodySmall?.copyWith(
                    color: KairoColors.textTertiary,
                  ),
                ),
                Text(
                  'Today',
                  style: textTheme.bodySmall?.copyWith(
                    color: KairoColors.textTertiary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  static String _shortDate(DateTime day) =>
      '${day.day.toString().padLeft(2, '0')}/'
      '${day.month.toString().padLeft(2, '0')}';
}

class _Bar extends StatelessWidget {
  const _Bar({required this.day});

  final DailyTally day;

  /// Enough height that a day with nothing on it still reads as a day.
  static const double _minimumFraction = 0.04;

  @override
  Widget build(BuildContext context) {
    final double fraction = day.due == 0
        ? _minimumFraction
        : _minimumFraction + day.completionRate * (1 - _minimumFraction);

    return Tooltip(
      message: day.due == 0
          ? '${_CompletionChart._shortDate(day.day)} · nothing came due'
          : '${_CompletionChart._shortDate(day.day)} · '
              '${day.completed} of ${day.due}',
      child: FractionallySizedBox(
        alignment: Alignment.bottomCenter,
        heightFactor: fraction,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: day.due == 0
                ? KairoColors.border
                : Color.lerp(
                    KairoColors.primarySubtle,
                    KairoColors.primary,
                    day.completionRate,
                  ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(KairoRadius.xs),
            ),
          ),
          child: const SizedBox(width: double.infinity),
        ),
      ),
    );
  }
}

/// Which kinds of care the user keeps up with, and which they let slide.
class _KindBreakdown extends ConsumerWidget {
  const _KindBreakdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<KindTally> tallies =
        ref.watch(kindTalliesProvider).valueOrNull ?? const <KindTally>[];

    return KairoCard(
      padding: const EdgeInsets.all(KairoSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('By reminder', style: textTheme.titleSmall),
          const SizedBox(height: KairoSpacing.md),
          if (tallies.isEmpty)
            Text(
              'Nothing has come due in this period yet.',
              style: textTheme.bodyMedium?.copyWith(
                color: KairoColors.textSecondary,
              ),
            )
          else
            for (final KindTally tally in tallies)
              Padding(
                padding: const EdgeInsets.only(bottom: KairoSpacing.md),
                child: Row(
                  children: <Widget>[
                    Icon(iconForKind(tally.kind), color: KairoColors.primary),
                    const SizedBox(width: KairoSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(tally.kind.name, style: textTheme.bodyLarge),
                          const SizedBox(height: KairoSpacing.xxs),
                          ClipRRect(
                            borderRadius: KairoRadius.pillBorderRadius,
                            child: LinearProgressIndicator(
                              value: tally.completionRate,
                              minHeight: KairoSpacing.xs,
                              backgroundColor: KairoColors.surfaceSubtle,
                              color: KairoColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: KairoSpacing.md),
                    Text(
                      '${tally.completed}/${tally.due}',
                      style: textTheme.bodyMedium?.copyWith(
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
