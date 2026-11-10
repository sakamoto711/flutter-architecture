import "dart:async";

import "package:flutter/foundation.dart";

import "use_case.dart";

export "/common/class/struct/result.dart";

/// InputPort呼出機構
///
/// [InputPort]を簡略化して呼び出すための機構です。
/// [InputPort]の実行結果を直接取得したい場合に、このクラスを使用してください。
/// [invoke]メソッドを使用することで、[InputPort]の実行結果を取得することができます。
/// 実行結果は[Result]型で返却されます。
///
/// 使用例
/// ```dart
///   final result = await InputPortInvoker(_fetchMenuListByCategoryIdInputPort).invoke(
///     FetchMenuListByCategoryIdInputPortParameter(categoryId: categoryId),
///   );
///
///   final menuList = await InputPortInvoker(_fetchMenuListByCategoryIdInputPort).invoke(
///     FetchMenuListByCategoryIdInputPortParameter(categoryId: categoryId),
///   ).unwrapOrThrow();
///
/// ```
@immutable
class InputPortInvoker<P extends InputPortParameter, T> {
  final InputPort<P, T> _inputPort;

  const InputPortInvoker(this._inputPort);

  /// 呼出
  ///
  /// InputPortの呼び出し結果に応じて[Result]型で返却します。
  /// 呼び出しが正常終了した場合は、[Success]型で返却します。
  /// 呼び出しで例外が発生した場合は、[Failure]型で返却します。
  ///
  /// [Failure.exception]には、以下のような例外が入る可能性があります。
  ///   • ドメイン層例外
  ///   • アプリケーション層例外
  ///   • 想定外の例外 → [UnexpectedThrowableException]
  /// が入る可能性があります。
  ///
  /// [outputPort]を省略またはnullにすると、呼び出しごとに標準OutputPortを生成します。
  /// 指定した場合は、そのインスタンスを使用します。
  Future<Result<T>> invoke(P parameter, [OutputPortMixin<T>? outputPort]) async {
    final resultOutputPort = outputPort ?? _ResultOutputPort<T>();
    try {
      await _inputPort.perform(parameter, resultOutputPort);
      return resultOutputPort.result;
    } catch (e) {
      return Failure(e);
    }
  }
}

class _ResultOutputPort<T> with OutputPortMixin<T> {}

/// 出力ポートmixin
///
/// 出力ポートの実装を簡易化するためのmixinです。
/// コールバック形式ではなく、処理結果をFuture型で返却可能です。
mixin OutputPortMixin<T> implements OutputPort<T> {
  Result<T>? _result;
  Result<T> get result {
    final self = _result;
    if (self == null) throw InputPortNotExecutedError();

    return self;
  }

  @override
  @nonVirtual
  void onSuccess(T result) {
    if (_result != null) throw InputPortAlreadyCompletedError();
    _result = Success(result);
  }

  @override
  @nonVirtual
  void onError(Exception e) {
    if (_result != null) throw InputPortAlreadyCompletedError();
    _result = Failure(e);
  }
}

/// 未試行のFutureエラー
///
/// 未試行のFutureの結果を取得しようとした場合にthrowされます
@immutable
class InputPortNotExecutedError extends Error {}

/// 完了済Futureへのアクセスエラー
///
/// 既に完了したFutureを再実行しようとした場合にthrowされます
@immutable
class InputPortAlreadyCompletedError extends Error {}
