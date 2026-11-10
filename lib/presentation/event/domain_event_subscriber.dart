import "package:meta/meta.dart";

import "/domain/shared/event/domain_event.dart";

/// ドメインイベント購読者
@immutable
abstract interface class DomainEventSubscriber {
  /// リスナー追加
  void addListener(DomainEventListener listener);

  /// リスナー削除
  void removeListener(DomainEventListener listener);
}

/// ドメインイベントリスナー
abstract interface class DomainEventListener {
  /// イベントが対象かどうかを判定します。
  bool isTarget(DomainEvent event);

  /// イベント受信
  void onDomainEvent(DomainEvent event);
}
