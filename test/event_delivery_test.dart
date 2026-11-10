import "package:flutter_architecture/common/event/event.dart";
import "package:flutter_architecture/common/event/event_subscriber.dart";
import "package:flutter_architecture/common/logger/logger.dart";
import "package:flutter_architecture/infrastructure/event/event_bus_impl.dart";
import "package:mocktail/mocktail.dart";
import "package:test/test.dart";

class _Log extends Mock implements Logger {}

class _Event extends Event {
  const _Event();
}

class _Listener implements EventListener {
  final bool Function() target;
  final void Function() receive;
  _Listener(this.receive, {bool Function()? target}) : target = target ?? (() => true);
  @override
  bool isTarget(Event event) => target();
  @override
  void onEvent(Event event) => receive();
}

void main() {
  for (final targetFails in [false, true]) {
    test("Delivery continues after ${targetFails ? 'matching' : 'notification'} fails", () {
      final logger = _Log();
      final bus = EventBusImpl(logger: logger);
      var received = 0;
      bus.addListener(
        _Listener(
          () {
            throw StateError("listener");
          },
          target: () {
            if (targetFails) throw StateError("matching");
            return true;
          },
        ),
      );
      bus.addListener(
        _Listener(() {
          received++;
        }),
      );
      bus.notify(const _Event());
      expect(received, 1);
      verify(
        () => logger.error(
          message: any(named: "message"),
          context: any(named: "context"),
          error: any(named: "error"),
          stackTrace: any(named: "stackTrace"),
        ),
      ).called(1);
    });
  }
  test("Broken diagnostics do not stop delivery", () {
    final logger = _Log();
    when(
      () => logger.error(
        message: any(named: "message"),
        context: any(named: "context"),
        error: any(named: "error"),
        stackTrace: any(named: "stackTrace"),
      ),
    ).thenThrow(StateError("logger"));
    final bus = EventBusImpl(logger: logger);
    var received = 0;
    bus.addListener(
      _Listener(() {
        throw StateError("listener");
      }),
    );
    bus.addListener(
      _Listener(() {
        received++;
      }),
    );
    bus.notify(const _Event());
    expect(received, 1);
  });
  test("Changes to subscriptions affect the next delivery", () {
    final bus = EventBusImpl(logger: _Log());
    final received = <String>[];
    final removed = _Listener(() => received.add("removed"));
    final added = _Listener(() => received.add("added"));
    bus.addListener(
      _Listener(() {
        received.add("first");
        bus.removeListener(removed);
        bus.addListener(added);
      }),
    );
    bus.addListener(removed);
    bus.notify(const _Event());
    expect(received, ["first"]);
    bus.notify(const _Event());
    expect(received, ["first", "first", "added"]);
  });
}
