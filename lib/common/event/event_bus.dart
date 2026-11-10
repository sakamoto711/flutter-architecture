import "package:meta/meta.dart";

import "event.dart";
import "event_subscriber.dart";

/// イベントバス
///
/// イベントを配送するための内部的な器です。
@immutable
abstract interface class EventBus {
  /// リスナー追加
  void addListener(EventListener listener);

  /// リスナー削除
  void removeListener(EventListener listener);

  /// イベント通知
  /// Delivery failures are recorded per listener; remaining listeners still receive the event.
  /// Delivery completion does not guarantee that asynchronous subscribers have refreshed.
  void notify(Event event);
}
