import "package:flutter/foundation.dart";

import "/common/class/exception/exception.dart";
import "/common/extension/object_extension.dart";
import "state.dart";

/// ステータス
///
/// [Phase]内での状態を表現します。
/// 下記のいずれかを取ります。
/// - [Ready]
/// - [Loading]
/// - [Complete]
/// - [Error]
sealed class Status implements State {}

/// 準備中
///
/// 処理が開始されていない状態です。
abstract interface class Ready extends Status {}

/// 処理開始可能な待機状態
abstract interface class StartableReady<L extends Loading> implements Ready {
  L start();
}

/// 読込中
///
/// 処理を実行中の状態です。
/// 処理が完了すると[Complete]状態に遷移します。
/// 処理でエラーが発生すると[Error]状態に遷移します。
abstract interface class Loading extends Status {
  // エラー発生時
  Error error(Object exception);
}

/// 完了
///
/// 処理が完了した状態です。
/// 処理結果[result]を保持します。
abstract interface class Complete<T> extends Status {
  // 処理結果
  T get result;
}

/// エラー発生
///
/// 処理でエラーが発生した状態です。
/// 発生した例外[exception]を保持します。
abstract interface class Error extends Status {
  // 例外
  Exception get exception;
}

/// エラー発生mixin
///
/// エラー発生時の例外を取得するためのmixinです。
/// `catch`した内容は[cause]で取得できます。
mixin ErrorMixin implements Error {
  @override
  @nonVirtual
  Exception get exception => cause.asOrNull<Exception>() ?? UnexpectedThrowableException(cause);

  // 根本例外
  Object get cause;
}

/// Ready変化可能
///
/// Readyに変化可能な状態を表現します。
abstract interface class ReadyShiftable<R extends Ready> {
  R ready();
}
