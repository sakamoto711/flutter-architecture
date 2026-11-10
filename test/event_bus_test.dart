import "package:flutter_architecture/common/event/event.dart";
import "package:flutter_architecture/common/event/event_subscriber.dart";
import "package:flutter_architecture/domain/counter/event/counter_changed.dart";
import "package:flutter_architecture/infrastructure/event/event_bus_impl.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("配信中の解除と追加は進行中のリスナー列を壊さない", () {
    final bus = EventBusImpl();
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
    bus.notify(const CounterChanged());
    expect(received, ["first"]);
    bus.notify(const CounterChanged());
    expect(received, ["first", "first", "added"]);
  });
}

class _Listener implements EventListener {
  final void Function() callback;
  const _Listener(this.callback);
  @override
  bool isTarget(Event event) => event is CounterChanged;
  @override
  void onEvent(Event event) => callback();
}
