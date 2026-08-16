import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo_ai/ai.dart';
import 'package:kairo_desktop_engine/desktop_engine.dart';
import 'package:kairo_event_bus/event_bus.dart';
import 'package:kairo_reminder_engine/reminder_engine.dart';
import 'package:kairo_scheduler/scheduler.dart';
import 'package:kairo_shared_models/shared_models.dart';
import 'package:kairo_storage/storage.dart';
import 'package:kairo_workflow_engine/workflow_engine.dart';

import '../app/app.dart';
import '../features/character/application/character_presence.dart';

/// Starts Kairo: brings the services up in dependency order, then runs the app.
///
/// The container is built here rather than by [ProviderScope] because the
/// services must be read before [runApp]. Passing that same container to
/// [UncontrolledProviderScope] keeps one container for the whole application.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ProviderContainer container = ProviderContainer();

  final UserSettings settings = await _startStorage(container);
  _startWorkflowEngine(container);
  await _startReminders(container);
  await _startCoach(container);
  await _startDesktopShell(container, settings);
  _startScheduler(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const KairoApp(),
    ),
  );
}

/// Opens the database, applies any migration, and reads the settings.
///
/// Drift would open lazily on the first query. Doing it at launch surfaces a
/// schema problem here rather than hours later, mid-reminder.
Future<UserSettings> _startStorage(ProviderContainer container) {
  return container.read(settingsRepositoryProvider).read();
}

/// Starts listening for the events that workflows react to.
///
/// Runs before anything registers a workflow or publishes an event: the bus
/// does not replay, so an event published before this reaches nobody.
void _startWorkflowEngine(ProviderContainer container) {
  container.read(workflowEngineProvider).start();
}

/// Seeds the default reminders and puts their schedules in place.
///
/// Awaited, so the schedules exist before the clock starts checking them.
Future<void> _startReminders(ProviderContainer container) {
  return container.read(reminderEngineProvider).start();
}

/// Starts the optional coach. Failure is swallowed: an unreachable model must
/// not stop the application coming up.
Future<void> _startCoach(ProviderContainer container) async {
  try {
    await container.read(coachProvider).start();
    await container.read(healthReporterProvider).start();
  } on Object catch (error, stack) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'kairo coach',
        context: ErrorDescription('starting the coach'),
        silent: true,
      ),
    );
  }
}

/// Starts the clock.
///
/// Last, so everything a due reminder must reach is already listening. The bus
/// does not replay.
void _startScheduler(ProviderContainer container) {
  container.read(schedulerProvider).start();
}

/// Shapes the main window and, if the user wants one, puts the character on
/// the desktop.
///
/// Shaped before the first frame is scheduled, so the user never sees the
/// window resize itself at launch.
Future<void> _startDesktopShell(
  ProviderContainer container,
  UserSettings settings,
) async {
  final KairoDesktopEngine engine = container.read(desktopEngineProvider);
  await engine.initialize(KairoWindowDescriptor.mainWindow);

  if (!settings.characterEnabled) {
    return;
  }

  try {
    // Positioned before it is shown. The character starts off the right edge of
    // its own window, so a window centred on the display would put the walk-on
    // in plain sight instead of off screen.
    final KairoNativeWindowController window = await engine.openWindow(
      KairoWindowDescriptor.characterWindow.at(
        characterPositionOn(await engine.activeDisplayBounds()),
      ),
    );

    // Not stored: its subscriptions keep it alive, and they live as long as the
    // event bus and channel do, which is as long as the application.
    CharacterPresence(
      channel: container.read(isolateChannelProvider),
      eventBus: container.read(eventBusProvider),
      service: container.read(reminderServiceProvider),
      coach: container.read(coachRepositoryProvider),
      engine: engine,
      window: window,
    ).start();
  } on Object catch (error, stack) {
    // Reported, not rethrown. If the platform refuses a second window the user
    // still gets their reminders, which is what Kairo is for.
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'kairo desktop shell',
        context: ErrorDescription('opening the character window'),
      ),
    );
  }
}
