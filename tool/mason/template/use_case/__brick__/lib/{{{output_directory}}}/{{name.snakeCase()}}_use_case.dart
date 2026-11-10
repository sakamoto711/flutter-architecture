import "dart:async";

import "/application/use_case.dart";

// FIXME: [must-delete-this-comment] `Never`型を正規の型に変更してください
// FIXME: [must-delete-this-comment] DartDocにUseCaseの和名を記載してください(例: カテゴリー一覧取得)

/// 入力ポート
abstract interface class {{name.pascalCase()}}InputPort
    implements InputPort<{{name.pascalCase()}}InputPortParameter, {{return_type}}> {}

/// ユースケース
class {{name.pascalCase()}}UseCase extends {{{super_class}}} implements {{name.pascalCase()}}InputPort {
  const {{name.pascalCase()}}UseCase({
    required super.logger,
{{^is_query}}
    required super.eventPublisher,
{{/is_query}}
  });

  @override
  Future<{{return_type}}> {{method_name}}({{name.pascalCase()}}InputPortParameter parameter) async {
    // FIXME: [must-delete-this-comment] 業務ロジックを実装してください
    throw UnimplementedError();
  }
}

/// 入力パラメータ
class {{name.pascalCase()}}InputPortParameter extends InputPortParameter {
  const {{name.pascalCase()}}InputPortParameter();

  @override
  void validate() {
    // FIXME: [must-delete-this-comment] 入力パラメータの検証を実装してください
  }

  @override
  List<Object?> get props => [];
}

/// 出力ポート
class {{name.pascalCase()}}OutputPort with OutputPortMixin<{{return_type}}> implements OutputPort<{{return_type}}> {}
