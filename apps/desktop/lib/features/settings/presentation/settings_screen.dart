import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kairo_ai/ai.dart';
import 'package:kairo_design_system/design_system.dart';
import 'package:kairo_shared_models/shared_models.dart';

import '../../../app/router.dart';
import '../../reminders/presentation/reminder_visuals.dart';
import '../application/settings_controller.dart';

/// Where the user tells Kairo how to behave.
///
/// Presentation only: every change is handed to [SettingsController], which is
/// what knows that turning the character off also means taking its window away.
class SettingsScreen extends ConsumerWidget {
  /// Creates the settings screen.
  const SettingsScreen({super.key});

  /// Keeps content readable when the window is stretched wide.
  static const double _maxWidth = 680;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserSettings? settings = ref.watch(settingsProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(KairoRoutes.dashboard),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        title: const Text('Settings'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: settings == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(KairoSpacing.xl),
                  children: <Widget>[
                    _QuietHoursCard(settings: settings),
                    const SizedBox(height: KairoSpacing.lg),
                    _CompanionCard(settings: settings),
                    const SizedBox(height: KairoSpacing.lg),
                    _StartupCard(settings: settings),
                    const SizedBox(height: KairoSpacing.lg),
                    _CoachCard(settings: settings),
                    const SizedBox(height: KairoSpacing.lg),
                    const _DataCard(),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Where coaching messages are written, if the user wants any.
class _CoachCard extends ConsumerStatefulWidget {
  const _CoachCard({required this.settings});

  final UserSettings settings;

  @override
  ConsumerState<_CoachCard> createState() => _CoachCardState();
}

class _CoachCardState extends ConsumerState<_CoachCard> {
  late final TextEditingController _baseUrl =
      TextEditingController(text: widget.settings.ai.baseUrl);
  late final TextEditingController _model =
      TextEditingController(text: widget.settings.ai.model);
  late final TextEditingController _apiKey =
      TextEditingController(text: widget.settings.ai.apiKey);

  String? _result;
  bool _testing = false;

  @override
  void dispose() {
    _baseUrl.dispose();
    _model.dispose();
    _apiKey.dispose();
    super.dispose();
  }

  AiSettings get _edited => widget.settings.ai.copyWith(
        baseUrl: _baseUrl.text.trim(),
        model: _model.text.trim(),
        apiKey: _apiKey.text.trim(),
      );

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AiSettings ai = widget.settings.ai;

    return KairoCard(
      padding: const EdgeInsets.all(KairoSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text('Coaching', style: textTheme.titleMedium),
              ),
              Switch(
                value: ai.enabled,
                onChanged: (bool enabled) =>
                    _save(_edited.copyWith(enabled: enabled)),
              ),
            ],
          ),
          const SizedBox(height: KairoSpacing.sm),
          Text(
            'Kairo can reword a reminder you keep putting off, write you a '
            'summary of how it is going, and say goodnight when your quiet '
            'hours begin. It needs a model to write with.',
            style: textTheme.bodyMedium?.copyWith(
              color: KairoColors.textSecondary,
            ),
          ),
          if (ai.enabled) ...<Widget>[
            const SizedBox(height: KairoSpacing.lg),
            TextField(
              controller: _baseUrl,
              decoration: const InputDecoration(
                labelText: 'Address',
                helperText: 'Ollama: http://localhost:11434/v1 · '
                    'LM Studio: http://localhost:1234/v1',
              ),
            ),
            const SizedBox(height: KairoSpacing.md),
            TextField(
              controller: _model,
              decoration: const InputDecoration(
                labelText: 'Model',
                hintText: 'llama3.2',
              ),
            ),
            const SizedBox(height: KairoSpacing.md),
            TextField(
              controller: _apiKey,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'API key',
                helperText: 'Leave empty for a model on this computer.',
              ),
            ),
            const SizedBox(height: KairoSpacing.md),
            Row(
              children: <Widget>[
                const Expanded(child: Text('Write a summary')),
                DropdownButton<Duration>(
                  value: AiSettings.reportIntervalChoices
                          .contains(ai.reportInterval)
                      ? ai.reportInterval
                      : AiSettings.defaultReportInterval,
                  borderRadius: KairoRadius.cardBorderRadius,
                  onChanged: (Duration? interval) {
                    if (interval != null) {
                      _save(_edited.copyWith(reportInterval: interval));
                    }
                  },
                  items: AiSettings.reportIntervalChoices
                      .map(
                        (Duration interval) => DropdownMenuItem<Duration>(
                          value: interval,
                          child: Text(describeInterval(interval)),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: KairoSpacing.md),
            Text(
              ai.isLocal
                  ? 'This model runs on your computer. Nothing leaves it.'
                  : 'How often you complete each reminder will be sent to '
                      '${Uri.tryParse(ai.baseUrl)?.host ?? 'that address'}.',
              style: textTheme.bodySmall?.copyWith(
                color:
                    ai.isLocal ? KairoColors.textSecondary : KairoColors.error,
              ),
            ),
            const SizedBox(height: KairoSpacing.lg),
            Row(
              children: <Widget>[
                FilledButton(
                  onPressed: _testing ? null : () => _save(_edited),
                  child: const Text('Save'),
                ),
                const SizedBox(width: KairoSpacing.md),
                TextButton(
                  onPressed: _testing ? null : _test,
                  child: Text(_testing ? 'Testing…' : 'Test connection'),
                ),
              ],
            ),
            if (_result != null) ...<Widget>[
              const SizedBox(height: KairoSpacing.md),
              SelectableText(
                _result!,
                style: textTheme.bodySmall?.copyWith(
                  color: KairoColors.textSecondary,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _save(AiSettings ai) async {
    setState(() => _result = null);
    await ref
        .read(settingsControllerProvider)
        .setAi(widget.settings, ai);
  }

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _result = null;
    });

    final AiSettings ai = _edited;
    String outcome;
    try {
      final String line = await const KairoAiClient().complete(
        settings: ai.copyWith(enabled: true),
        system: coachSystemPrompt,
        prompt: 'Say hello to someone sitting down at their desk.',
      );
      outcome = 'It works. The model said: "$line"';
    } on KairoAiException catch (error) {
      outcome = error.message;
    } on Object catch (error) {
      outcome = 'That did not work: $error';
    }

    if (mounted) {
      setState(() {
        _testing = false;
        _result = outcome;
      });
    }
  }
}

/// The stretch of the day Kairo says nothing at all.
class _QuietHoursCard extends ConsumerWidget {
  const _QuietHoursCard({required this.settings});

  final UserSettings settings;

  /// What quiet hours default to when first switched on.
  static const DailyWindow _overnight = DailyWindow(from: 22 * 60, to: 7 * 60);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final SettingsController controller =
        ref.watch(settingsControllerProvider);
    final DailyWindow? quiet = settings.quietHours;

    return KairoCard(
      padding: const EdgeInsets.all(KairoSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Quiet hours', style: textTheme.titleMedium),
                    const SizedBox(height: KairoSpacing.xxs),
                    Text(
                      'Kairo shows nothing at all during these hours, whatever '
                      'each reminder says.',
                      style: textTheme.bodySmall?.copyWith(
                        color: KairoColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: KairoSpacing.md),
              Switch(
                value: quiet != null,
                onChanged: (bool on) => controller.setQuietHours(
                  settings,
                  on ? _overnight : null,
                ),
              ),
            ],
          ),
          if (quiet != null) ...<Widget>[
            const SizedBox(height: KairoSpacing.lg),
            Row(
              children: <Widget>[
                _TimeButton(
                  label: 'From',
                  minuteOfDay: quiet.from,
                  onChanged: (int minute) => controller.setQuietHours(
                    settings,
                    DailyWindow(from: minute, to: quiet.to),
                  ),
                ),
                const SizedBox(width: KairoSpacing.md),
                _TimeButton(
                  label: 'Until',
                  minuteOfDay: quiet.to,
                  onChanged: (int minute) => controller.setQuietHours(
                    settings,
                    DailyWindow(from: quiet.from, to: minute),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A button showing a time, which opens a picker when pressed.
class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.minuteOfDay,
    required this.onChanged,
  });

  final String label;
  final int minuteOfDay;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final TimeOfDay time = TimeOfDay(
      hour: minuteOfDay ~/ 60,
      minute: minuteOfDay % 60,
    );

    return OutlinedButton(
      onPressed: () async {
        final TimeOfDay? chosen = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (chosen != null) {
          onChanged(chosen.hour * 60 + chosen.minute);
        }
      },
      child: Text('$label  ${time.format(context)}'),
    );
  }
}

/// How the companion makes itself known.
class _CompanionCard extends ConsumerWidget {
  const _CompanionCard({required this.settings});

  final UserSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final SettingsController controller =
        ref.watch(settingsControllerProvider);

    return KairoCard(
      padding: const EdgeInsets.all(KairoSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Companion', style: textTheme.titleMedium),
          const SizedBox(height: KairoSpacing.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: settings.characterEnabled,
            onChanged: (bool on) =>
                controller.setCharacterEnabled(settings, on),
            title: const Text('Show the character'),
            subtitle: const Text(
              'Reminders keep working either way. They simply arrive without '
              'the companion.',
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: settings.soundEnabled,
            onChanged: (bool on) => controller.setSoundEnabled(settings, on),
            title: const Text('Play a sound'),
            subtitle: const Text(
              'Uses the system alert sound when a reminder arrives.',
            ),
          ),
        ],
      ),
    );
  }
}

/// Whether Kairo is there without being asked for.
class _StartupCard extends ConsumerWidget {
  const _StartupCard({required this.settings});

  final UserSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final SettingsController controller = ref.watch(settingsControllerProvider);

    // The system's answer, not the stored one. A login item can be removed in
    // System Settings while Kairo is not running, and a switch showing what
    // Kairo last wrote would then be showing something untrue.
    final AsyncValue<bool> registered = ref.watch(launchesAtLoginProvider);

    return KairoCard(
      padding: const EdgeInsets.all(KairoSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Startup', style: textTheme.titleMedium),
          const SizedBox(height: KairoSpacing.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: registered.valueOrNull ?? settings.launchAtLogin,
            onChanged: registered.isLoading
                ? null
                : (bool on) async {
                    try {
                      await controller.setLaunchAtLogin(settings, on);
                    } on Object catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'macOS would not change the login item: $error',
                            ),
                          ),
                        );
                      }
                    }
                    ref.invalidate(launchesAtLoginProvider);
                  },
            title: const Text('Start Kairo when I log in'),
            subtitle: const Text(
              'Kairo runs in the menu bar and only appears in the dock while '
              'this dashboard is open.',
            ),
          ),
        ],
      ),
    );
  }
}

/// Taking the data out, and getting rid of it.
class _DataCard extends ConsumerStatefulWidget {
  const _DataCard();

  @override
  ConsumerState<_DataCard> createState() => _DataCardState();
}

class _DataCardState extends ConsumerState<_DataCard> {
  String? _lastExportPath;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return KairoCard(
      padding: const EdgeInsets.all(KairoSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Your data', style: textTheme.titleMedium),
          const SizedBox(height: KairoSpacing.xxs),
          Text(
            'Everything Kairo knows lives on this machine and is never sent '
            'anywhere. You can take a copy, or destroy it.',
            style: textTheme.bodySmall?.copyWith(
              color: KairoColors.textSecondary,
            ),
          ),
          const SizedBox(height: KairoSpacing.lg),
          Row(
            children: <Widget>[
              FilledButton(
                onPressed: _busy ? null : _export,
                child: const Text('Export as JSON'),
              ),
              const SizedBox(width: KairoSpacing.md),
              TextButton(
                onPressed: _busy ? null : _confirmDelete,
                style: TextButton.styleFrom(
                  foregroundColor: KairoColors.error,
                ),
                child: const Text('Delete everything'),
              ),
            ],
          ),
          if (_lastExportPath != null) ...<Widget>[
            const SizedBox(height: KairoSpacing.md),
            SelectableText(
              'Saved to $_lastExportPath',
              style: textTheme.bodySmall?.copyWith(
                color: KairoColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final File file =
          await ref.read(settingsControllerProvider).exportData();
      if (mounted) {
        setState(() => _lastExportPath = file.path);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Delete everything?'),
            content: const Text(
              'Every reminder, every day of history and every preference will '
              'be destroyed. This cannot be undone, and Kairo keeps no copy '
              'anywhere else.\n\n'
              'The default reminders will come back the next time Kairo '
              'starts. Your history will not.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: KairoColors.error,
                ),
                child: const Text('Delete everything'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    setState(() => _busy = true);
    try {
      await ref.read(settingsControllerProvider).deleteEverything();
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _lastExportPath = null;
        });
      }
    }
  }
}
