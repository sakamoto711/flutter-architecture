import "package:equatable/equatable.dart";
import "package:flutter/foundation.dart";

import "output_port.dart";

export "exception.dart";

/// 入力ポート
///
/// 入力ポートは、ユースケースの入力を表現します。
/// ユースケースを実行するためには、このインターフェースを実装する必要があります。
abstract interface class InputPort<P extends InputPortParameter, T> {
  /// 入力ポートの実行
  ///
  /// 入力ポートの実行を行います。
  Future<void> perform(P parameter, OutputPort<T> outputPort);
}

/// 入力ポートパラメータ
///
/// ユースケースの入力パラメータを表現するインターフェースです。
/// すべての入力パラメータクラスはこのインターフェースを実装する必要があります。
@immutable
abstract class InputPortParameter with EquatableMixin {
  const InputPortParameter();

  /// 入力パラメータの検証
  ///
  /// 入力パラメータの検証を実施します。
  /// 入力パラメータの検証に失敗した場合は、例外をthrowしてください。
  ///
  /// 基本的には`ValueObject`単体で検証を行いますが、組み合わせで検証を行いたい場合は、このメソッドをオーバーライドしてください。
  /// このメソッドで非同期処理や副作用のある処理は実施しないでください。
  void validate();

  @override
  @nonVirtual
  bool get stringify => true;
}
