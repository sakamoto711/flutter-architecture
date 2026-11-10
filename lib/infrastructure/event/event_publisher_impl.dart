import "/common/event/event.dart";
import "/common/event/event_bus.dart";
import "/common/event/event_publisher.dart";

/// EventBusを利用するイベント発行者
class EventPublisherImpl implements EventPublisher {
  final EventBus _eventBus;

  const EventPublisherImpl(this._eventBus);

  @override
  void publish(Event event) {
    _eventBus.notify(event);
  }
}
