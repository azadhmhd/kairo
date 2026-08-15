import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairo_event_bus/event_bus.dart';

class _SomethingHappened extends KairoEvent {
  const _SomethingHappened(this.detail);

  final String detail;
}

class _SomethingElseHappened extends KairoEvent {
  const _SomethingElseHappened();
}

void main() {
  test('a published event reaches a listener', () async {
    final KairoEventBus bus = KairoEventBus();
    addTearDown(bus.dispose);

    final Future<KairoEvent> received = bus.events.first;
    bus.publish(const _SomethingHappened('water'));

    expect(received, completion(isA<_SomethingHappened>()));
  });

  test('listening for one kind of event ignores the others', () async {
    final KairoEventBus bus = KairoEventBus();
    addTearDown(bus.dispose);

    final Future<List<_SomethingHappened>> matching =
        bus.on<_SomethingHappened>().take(2).toList();

    bus.publish(const _SomethingHappened('first'));
    bus.publish(const _SomethingElseHappened());
    bus.publish(const _SomethingHappened('second'));

    expect(
      await matching,
      <Matcher>[
        isA<_SomethingHappened>().having(
          (_SomethingHappened event) => event.detail,
          'detail',
          'first',
        ),
        isA<_SomethingHappened>().having(
          (_SomethingHappened event) => event.detail,
          'detail',
          'second',
        ),
      ],
    );
  });

  test('every listener receives every event', () async {
    final KairoEventBus bus = KairoEventBus();
    addTearDown(bus.dispose);

    final Future<KairoEvent> first = bus.events.first;
    final Future<KairoEvent> second = bus.events.first;

    bus.publish(const _SomethingHappened('shared'));

    expect(await first, isA<_SomethingHappened>());
    expect(await second, isA<_SomethingHappened>());
  });

  test('publishing to a disposed bus fails rather than vanishing', () async {
    final KairoEventBus bus = KairoEventBus();
    await bus.dispose();

    expect(bus.isDisposed, isTrue);
    expect(
      () => bus.publish(const _SomethingHappened('too late')),
      throwsStateError,
    );
  });

  test('the bus is closed with the container that provided it', () async {
    final ProviderContainer container = ProviderContainer();
    final KairoEventBus bus = container.read(eventBusProvider);

    expect(bus.isDisposed, isFalse);

    container.dispose();

    expect(bus.isDisposed, isTrue);
  });
}
