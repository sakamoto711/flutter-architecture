import "/presentation/bloc/share/bloc/state.dart";
import "{{name.snakeCase()}}_state_data.dart";

export "{{name.snakeCase()}}_state_data.dart";

// FIXME: [must-delete-this-comment] DartDocにBLoCの和名を記載してください(例: カテゴリー一覧BLoC)


/// BLoC - 状態
sealed class {{name.pascalCase()}}State implements State {}

///////////////////
/// 初期化フェーズ
///////////////////

/// BLoC - 初期化フェーズ - 待機
class {{name.pascalCase()}}InitializeReadyState extends InitializeReady implements {{name.pascalCase()}}State {
  @override
  {{name.pascalCase()}}InitializeLoadingState start() => {{name.pascalCase()}}InitializeLoadingState();
}

/// BLoC - 初期化フェーズ - 読込中
class {{name.pascalCase()}}InitializeLoadingState extends InitializeLoading<{{name.pascalCase()}}StateData> implements {{name.pascalCase()}}State {
  @override
  {{name.pascalCase()}}InitializeCompleteState complete({{name.pascalCase()}}StateData data) => {{name.pascalCase()}}InitializeCompleteState(data);

  @override
  {{name.pascalCase()}}InitializeErrorState error(Object cause) => {{name.pascalCase()}}InitializeErrorState(cause);
}

/// BLoC - 初期化フェーズ - 完了
class {{name.pascalCase()}}InitializeCompleteState extends InitializeComplete<{{name.pascalCase()}}StateData>
    with PhaseShiftable<{{name.pascalCase()}}PostInitializedReadyState, {{name.pascalCase()}}StateData>
    implements {{name.pascalCase()}}State {
  {{name.pascalCase()}}InitializeCompleteState(super.result);

  @override
  {{name.pascalCase()}}PostInitializedReadyState shift() => {{name.pascalCase()}}PostInitializedReadyState(result);
}

/// BLoC - 初期化フェーズ - エラー
class {{name.pascalCase()}}InitializeErrorState extends InitializeError implements {{name.pascalCase()}}State {
  {{name.pascalCase()}}InitializeErrorState(super.exception);

  @override
  {{name.pascalCase()}}InitializeReadyState ready() => {{name.pascalCase()}}InitializeReadyState();
}

//////////////////////
/// 初期化完了フェーズ
//////////////////////

/// BLoC - 初期化完了フェーズ - 待機
class {{name.pascalCase()}}PostInitializedReadyState extends PostInitializedStartableReady<{{name.pascalCase()}}StateData> implements {{name.pascalCase()}}State {
  {{name.pascalCase()}}PostInitializedReadyState(super.data);

  @override
  {{name.pascalCase()}}PostInitializedLoadingState start() => {{name.pascalCase()}}PostInitializedLoadingState(data);
}

/// BLoC - 初期化完了フェーズ - 読込中
class {{name.pascalCase()}}PostInitializedLoadingState extends PostInitializedLoading<{{name.pascalCase()}}StateData> implements {{name.pascalCase()}}State {
  {{name.pascalCase()}}PostInitializedLoadingState(super.data);

  @override
  {{name.pascalCase()}}PostInitializedCompleteState<T> complete<T>({{name.pascalCase()}}StateData data, T result) => {{name.pascalCase()}}PostInitializedCompleteState<T>(data, result);

  @override
  {{name.pascalCase()}}PostInitializedErrorState error(Object cause) => {{name.pascalCase()}}PostInitializedErrorState(data, cause);
}

/// BLoC - 初期化完了フェーズ - 完了
class {{name.pascalCase()}}PostInitializedCompleteState<T> extends PostInitializedComplete<{{name.pascalCase()}}StateData, T> implements {{name.pascalCase()}}State {
  {{name.pascalCase()}}PostInitializedCompleteState(super.data, super.result);

  @override
  {{name.pascalCase()}}PostInitializedReadyState ready() => {{name.pascalCase()}}PostInitializedReadyState(data);
}

/// BLoC - 初期化完了フェーズ - エラー
class {{name.pascalCase()}}PostInitializedErrorState extends PostInitializedError<{{name.pascalCase()}}StateData> implements {{name.pascalCase()}}State {
  {{name.pascalCase()}}PostInitializedErrorState(super.data, super.cause);

  @override
  {{name.pascalCase()}}PostInitializedReadyState ready() => {{name.pascalCase()}}PostInitializedReadyState(data);
}
