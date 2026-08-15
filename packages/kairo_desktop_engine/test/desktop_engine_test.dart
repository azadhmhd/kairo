import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairo_desktop_engine/desktop_engine.dart';
import 'package:kairo_event_bus/event_bus.dart';

/// A window service that records what it was asked to do instead of reaching
/// for the platform, so the startup wiring can be tested without a window.
class _RecordingWindowService extends KairoWindowService {
  KairoWindowDescriptor? appliedDescriptor;

  @override
  Future<void> applyStartupDescriptor(KairoWindowDescriptor descriptor) async {
    appliedDescriptor = descriptor;
  }
}

/// A controller that does nothing, for tests that only care about identity.
class _InertWindowController implements KairoWindowController {
  @override
  Future<void> show() async {}

  @override
  Future<void> hide() async {}

  @override
  Future<void> focus() async {}

  @override
  Future<void> close() async {}

  @override
  Future<void> move(Offset position) async {}

  @override
  Future<void> resize(Size size) async {}

  @override
  Future<Rect> bounds() async => Rect.zero;

  @override
  Future<bool> isVisible() async => true;
}

KairoDesktopEngine _engineWith(
  _RecordingWindowService service, {
  KairoWindowRegistry? registry,
  KairoEventBus? eventBus,
}) {
  return KairoDesktopEngine(
    windowService: service,
    registry: registry ?? KairoWindowRegistry(),
    eventBus: eventBus ?? KairoEventBus(),
  );
}

void main() {
  test('the engine hands the startup descriptor to the window service', () async {
    final _RecordingWindowService service = _RecordingWindowService();

    await _engineWith(service).initialize(KairoWindowDescriptor.mainWindow);

    expect(service.appliedDescriptor, KairoWindowDescriptor.mainWindow);
  });

  test('starting up makes the main window reachable by its identity', () async {
    final _RecordingWindowService service = _RecordingWindowService();
    final KairoWindowRegistry registry = KairoWindowRegistry();
    final KairoDesktopEngine engine = _engineWith(
      service,
      registry: registry,
    );

    expect(registry.registeredIds, isEmpty);

    await engine.initialize(KairoWindowDescriptor.mainWindow);

    expect(registry.controller(KairoWindowId.main), same(service));
    expect(registry.registeredIds, <KairoWindowId>[KairoWindowId.main]);
  });

  test('starting up announces the window it opened', () async {
    final _RecordingWindowService service = _RecordingWindowService();
    final KairoEventBus eventBus = KairoEventBus();
    addTearDown(eventBus.dispose);
    final KairoDesktopEngine engine = _engineWith(service, eventBus: eventBus);

    final Future<KairoWindowOpened> announced =
        eventBus.on<KairoWindowOpened>().first;

    await engine.initialize(KairoWindowDescriptor.mainWindow);

    expect((await announced).id, KairoWindowId.main);
  });

  test('the window service can drive any window through the controller interface', () {
    expect(const KairoWindowService(), isA<KairoWindowController>());
  });

  test('a registered window resolves to the controller that was registered', () {
    final KairoWindowRegistry registry = KairoWindowRegistry();
    final _InertWindowController controller = _InertWindowController();

    registry.register(KairoWindowId.character, controller);

    expect(registry.controller(KairoWindowId.character), same(controller));
    expect(registry.maybeController(KairoWindowId.character), same(controller));
  });

  test('asking for a window that does not exist fails and names it', () {
    final KairoWindowRegistry registry = KairoWindowRegistry();

    expect(
      () => registry.controller(KairoWindowId.character),
      throwsA(
        isA<StateError>().having(
          (StateError error) => error.message,
          'message',
          contains("'character'"),
        ),
      ),
    );
    expect(registry.maybeController(KairoWindowId.character), isNull);
  });

  test('registering a window twice fails rather than replacing it', () {
    final KairoWindowRegistry registry = KairoWindowRegistry();
    registry.register(KairoWindowId.main, _InertWindowController());

    expect(
      () => registry.register(KairoWindowId.main, _InertWindowController()),
      throwsStateError,
    );
  });

  test('unregistering a window makes it unreachable again', () {
    final KairoWindowRegistry registry = KairoWindowRegistry();
    registry.register(KairoWindowId.main, _InertWindowController());

    registry.unregister(KairoWindowId.main);

    expect(registry.maybeController(KairoWindowId.main), isNull);
    expect(registry.registeredIds, isEmpty);

    // Unregistering again is not an error: the window is already gone.
    registry.unregister(KairoWindowId.main);
  });

  test('two windows of the same type are two different windows', () {
    const KairoWindowId water = KairoWindowId(
      KairoWindowType.reminder,
      'water',
    );
    const KairoWindowId stand = KairoWindowId(
      KairoWindowType.reminder,
      'stand',
    );
    const KairoWindowId alsoWater = KairoWindowId(
      KairoWindowType.reminder,
      'water',
    );

    expect(water, isNot(stand));
    expect(water, alsoWater);
    expect(water.hashCode, alsoWater.hashCode);

    final KairoWindowRegistry registry = KairoWindowRegistry();
    registry.register(water, _InertWindowController());
    registry.register(stand, _InertWindowController());

    expect(registry.registeredIds, hasLength(2));
    expect(
      registry.controller(alsoWater),
      same(registry.controller(water)),
    );
  });

  test('a window without an instance is not the same as one with an instance', () {
    const KairoWindowId anyReminder = KairoWindowId(KairoWindowType.reminder);
    const KairoWindowId namedReminder = KairoWindowId(
      KairoWindowType.reminder,
      'water',
    );

    expect(anyReminder, isNot(namedReminder));
  });

  test('window ids read well in the errors that quote them', () {
    expect(KairoWindowId.main.toString(), 'main');
    expect(
      const KairoWindowId(KairoWindowType.reminder, 'water').toString(),
      'reminder#water',
    );
  });

  test('the engine provider is wired to the service, registry and bus', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final KairoDesktopEngine engine = container.read(desktopEngineProvider);

    expect(engine.windowService, same(container.read(windowServiceProvider)));
    expect(engine.registry, same(container.read(windowRegistryProvider)));
    expect(engine.eventBus, same(container.read(eventBusProvider)));
  });

  test('window descriptors compare by value', () {
    const KairoWindowDescriptor descriptor = KairoWindowDescriptor(
      id: KairoWindowId.main,
      size: Size(800, 600),
      minimumSize: Size(400, 300),
      title: 'Kairo',
    );
    const KairoWindowDescriptor same = KairoWindowDescriptor(
      id: KairoWindowId.main,
      size: Size(800, 600),
      minimumSize: Size(400, 300),
      title: 'Kairo',
    );
    const KairoWindowDescriptor otherWindow = KairoWindowDescriptor(
      id: KairoWindowId.settings,
      size: Size(800, 600),
      minimumSize: Size(400, 300),
      title: 'Kairo',
    );
    const KairoWindowDescriptor floating = KairoWindowDescriptor(
      id: KairoWindowId.main,
      size: Size(800, 600),
      minimumSize: Size(400, 300),
      title: 'Kairo',
      alwaysOnTop: true,
    );

    expect(descriptor, same);
    expect(descriptor.hashCode, same.hashCode);
    expect(descriptor, isNot(otherWindow));
    expect(descriptor, isNot(floating));
  });

  test('the main window opens no smaller than it can be resized', () {
    const KairoWindowDescriptor descriptor = KairoWindowDescriptor.mainWindow;

    expect(descriptor.id, KairoWindowId.main);
    expect(
      descriptor.size.width,
      greaterThanOrEqualTo(descriptor.minimumSize.width),
    );
    expect(
      descriptor.size.height,
      greaterThanOrEqualTo(descriptor.minimumSize.height),
    );
  });
}
