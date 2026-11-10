import "/application/outbound_port/domain_event_publisher.dart";
import "/common/event/event_publisher.dart";
import "/domain/shared/event/domain_event.dart";

/// EventBusを利用するドメインイベント発行者
class DomainEventPublisherImpl implements DomainEventPublisher {
  final EventPublisher _eventPublisher;

  const DomainEventPublisherImpl(this._eventPublisher);

  @override
  void publish(DomainEvent event) {
    _eventPublisher.publish(event);
  }
}
