import "package:equatable/equatable.dart";
import "package:flutter/foundation.dart";

import "state.dart";

/// State内データ
///
/// [DataHolding]のジェネリクスで使用するデータを表現します。
/// 単一のドメインオブジェクトではなく、複数のドメインオブジェクトを保持したい場合に当クラスを利用してください。
@immutable
abstract class StateData extends Equatable {
  const StateData();
}
