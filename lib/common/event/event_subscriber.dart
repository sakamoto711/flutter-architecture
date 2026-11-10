import "package:meta/meta.dart";

import "event.dart";

/// イベント購読者
@immutable
abstract interface class EventSubscriber {
  /// リスナー追加
  void addListener(EventListener listener);

  /// リスナー削除
  void removeListener(EventListener listener);
}

/// イベントリスナー
abstract interface class EventListener {
  /// イベントが対象かどうかを判定します。
  bool isTarget(Event event);

  /// イベント受信
  void onEvent(Event event);
}
