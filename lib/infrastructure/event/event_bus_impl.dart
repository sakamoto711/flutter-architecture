import "/common/event/event.dart";
import "/common/event/event_bus.dart";
import "/common/event/event_subscriber.dart";
import "/common/logger/logger.dart";

/// イベントバス実装
class EventBusImpl implements EventBus {
  final Logger logger;
  EventBusImpl({required this.logger});
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
    final listeners = _listenerCollection.toList(growable: false);
    for (final listener in listeners) {
      if (!_listenerCollection.contains(listener)) continue;
      try {
        if (listener.isTarget(event)) listener.onEvent(event);
      } catch (error, stackTrace) {
        // Diagnostics must never turn a committed operation into a failure.
        try {
          logger.error(
            message: "イベント配送に失敗",
            context: Context({"event": event.runtimeType, "listener": listener.runtimeType}),
            error: error,
            stackTrace: stackTrace,
          );
        } catch (_) {
          // A broken logger must not prevent delivery to the remaining listeners.
        }
      }
    }
  }
}
