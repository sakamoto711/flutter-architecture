import "/common/typedef/future_or_typedef.dart";

/// 出力ポート
///
/// 出力ポートは、ユースケースの出力を表現します。
/// ユースケースの実行結果を取得するためには、このポートを実装する必要があります。
abstract interface class OutputPort<T> {
  /// 成功時
  ///
  /// ユースケースの実行が成功した場合に呼び出されます。
  /// この処理で発生した例外は呼び出し元へ伝播し、[onError]には通知されません。
  VoidFutureOr onSuccess(T result);

  /// エラー発生時
  ///
  /// ユースケースの実行で例外が発生した場合に呼び出されます。
  /// [stackTrace] は元の失敗箇所の情報を保持します。
  VoidFutureOr onError(Exception e, StackTrace stackTrace);
}
