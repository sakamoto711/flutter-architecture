import "package:meta/meta.dart";

import "event.dart";

/// イベント発行者
@immutable
abstract interface class EventPublisher {
  /// イベント通知
  void publish(Event event);
}
