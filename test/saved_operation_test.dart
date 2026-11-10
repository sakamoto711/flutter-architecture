import "package:flutter_architecture/application/counter/command/increment_counter_use_case.dart";
import "package:flutter_architecture/application/helper.dart";
import "package:flutter_architecture/common/event/event.dart";
import "package:flutter_architecture/common/event/event_subscriber.dart";
import "package:flutter_architecture/common/logger/noop_logger.dart";
import "package:flutter_architecture/infrastructure/event/domain_event_publisher_impl.dart";
import "package:flutter_architecture/infrastructure/event/event_bus_impl.dart";
import "package:flutter_architecture/infrastructure/event/event_publisher_impl.dart";
import "package:flutter_architecture/infrastructure/repository/counter/in_memory_counter_repository.dart";
import "package:test/test.dart";

class _Listener implements EventListener {
  final void Function() action;
  _Listener(this.action);
  @override
  bool isTarget(Event event) => true;
  @override
  void onEvent(Event event) => action();
}

void main() {
  test("Committed operation succeeds once even when a subscriber fails", () async {
    const logger = NoopLogger();
    final bus = EventBusImpl(logger: logger);
    var received = 0;
    bus.addListener(
      _Listener(() {
        throw StateError("subscriber");
      }),
    );
    bus.addListener(
      _Listener(() {
        received++;
      }),
    );
    final publisher = DomainEventPublisherImpl(EventPublisherImpl(bus));
    final repository = InMemoryCounterRepository();
    final command = IncrementCounterUseCase(repository: repository, logger: logger, eventPublisher: publisher);
    final result = await InputPortInvoker(command).invoke(const IncrementCounterInputPortParameter());
    expect(result, isA<Success<void>>());
    expect(repository.fetch().value, 1);
    expect(received, 1);
  });
}
