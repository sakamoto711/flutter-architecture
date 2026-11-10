import "/common/event/event.dart";
import "/common/event/event_subscriber.dart";
import "/domain/shared/event/domain_event.dart";
import "domain_event_subscriber.dart";

/// EventSubscriberを利用するドメインイベント購読者
class DomainEventSubscriberImpl implements DomainEventSubscriber {
  final EventSubscriber _eventSubscriber;
  final _listenerMap = <DomainEventListener, EventListener>{};

  DomainEventSubscriberImpl(this._eventSubscriber);

  @override
  void addListener(DomainEventListener listener) {
    if (_listenerMap.containsKey(listener)) return;

    final adapter = _DomainEventListenerAdapter(listener);
    _listenerMap[listener] = adapter;
    _eventSubscriber.addListener(adapter);
  }

  @override
  void removeListener(DomainEventListener listener) {
    final adapter = _listenerMap.remove(listener);
    if (adapter != null) _eventSubscriber.removeListener(adapter);
  }
}

class _DomainEventListenerAdapter implements EventListener {
  final DomainEventListener _listener;

  const _DomainEventListenerAdapter(this._listener);

  @override
  bool isTarget(Event event) => event is DomainEvent && _listener.isTarget(event);

  @override
  void onEvent(Event event) {
    if (event is DomainEvent) _listener.onDomainEvent(event);
  }
}
