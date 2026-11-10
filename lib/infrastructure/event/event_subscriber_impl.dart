import "/common/event/event_bus.dart";
import "/common/event/event_subscriber.dart";

/// EventBusを利用するイベント購読者
class EventSubscriberImpl implements EventSubscriber {
  final EventBus _eventBus;

  const EventSubscriberImpl(this._eventBus);

  @override
  void addListener(EventListener listener) {
    _eventBus.addListener(listener);
  }

  @override
  void removeListener(EventListener listener) {
    _eventBus.removeListener(listener);
  }
}
