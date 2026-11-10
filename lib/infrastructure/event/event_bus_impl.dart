import "/common/event/event.dart";
import "/common/event/event_bus.dart";
import "/common/event/event_subscriber.dart";

/// イベントバス実装
class EventBusImpl implements EventBus {
  final _listenerCollection = <EventListener>{};

  @override
  void addListener(EventListener listener) {
    _listenerCollection.add(listener);
  }

  @override
  void removeListener(EventListener listener) {
    _listenerCollection.remove(listener);
  }

  @override
  void notify(Event event) {
    // 配信中の購読解除・追加で反復対象を変更しない。
    final listeners = _listenerCollection.toList(growable: false);
    for (final listener in listeners) {
      if (_listenerCollection.contains(listener) && listener.isTarget(event)) {
        listener.onEvent(event);
      }
    }
  }
}
