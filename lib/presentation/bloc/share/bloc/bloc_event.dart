import "/common/event/event.dart";

export "/common/event/event.dart";

/// BLoCイベント
///
/// BLoCに関連するイベントを表現します。
abstract class BlocEvent extends Event {
  const BlocEvent();
}

/// BLoCの初期ロードを要求するEventの契約
abstract interface class InitialLoadRequested implements BlocEvent {}
