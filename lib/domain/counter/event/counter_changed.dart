import "/domain/shared/event/domain_event.dart";

/// 保存完了を通知する。購読者は必要なデータを再取得する。
final class CounterChanged extends DomainEvent {
  const CounterChanged();

  @override
  List<Object?> get props => [];
}
