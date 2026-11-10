import "package:meta/meta.dart";

import "/domain/shared/event/domain_event.dart";

/// ドメインイベントの発行を外部へ依頼するポートです。
@immutable
abstract interface class DomainEventPublisher {
  void publish(DomainEvent event);
}
