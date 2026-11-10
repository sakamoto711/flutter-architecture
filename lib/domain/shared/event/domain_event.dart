import "package:equatable/equatable.dart";

import "/common/event/event.dart";

/// ドメインイベント
///
/// ドメイン層で発生するイベントを表現します。
/// ex.) 注文が作成された、注文が更新された など
abstract class DomainEvent extends Event with EquatableMixin {
  const DomainEvent();

  @override
  List<Object?> get props;
}
