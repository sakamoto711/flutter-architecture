import "package:flutter/foundation.dart";

import "state.dart";

/// フェーズ
///
/// [State]において、どのフェーズにいるかを表現します。
/// - [Initialize]
/// - [PostInitialized]
sealed class Phase implements State {}

/// 初期化フェーズ
///
/// このフェーズでは`BLoC`の初期状態を設定し、必要な初期データを取得します。
/// 主に初期表示に必要なデータの取得を行う場合に使用してください。
/// データ準備が完了すると[PostInitialized]フェーズに移行します。
abstract interface class Initialize implements Phase {}

/// 初期化後フェーズ
///
/// このフェーズでは、初回読み込み完了後の追加処理を実施します。
/// 主に初回読み込みしたデータを用いて処理を実施する場合に使用してください。
/// `BLoC`を破棄しない限り、このフェーズは維持されます。
abstract interface class PostInitialized<T> implements Phase, DataHolding<T> {}

/// フェーズ移行可能
///
/// フェーズ移行可能なフェーズを表現します。
/// フェーズ移行可能なフェーズは、[Initialize]フェーズから[PostInitialized]フェーズに移行することができます。
mixin PhaseShiftable<R extends PostInitializedReady<T>, T> implements ReadyShiftable<R> {
  @override
  @nonVirtual
  R ready() => shift();

  R shift();
}
