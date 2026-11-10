import "/presentation/bloc/share/bloc/state.dart";
import "counter_state_data.dart";

export "counter_state_data.dart";

/// BLoC - 状態
sealed class CounterState implements State {}

///////////////////
/// 初期化フェーズ
///////////////////

/// BLoC - 初期化フェーズ - 待機
class CounterInitializeReadyState extends InitializeReady implements CounterState {
  @override
  CounterInitializeLoadingState start() => CounterInitializeLoadingState();
}

/// BLoC - 初期化フェーズ - 読込中
class CounterInitializeLoadingState extends InitializeLoading<CounterStateData> implements CounterState {
  @override
  CounterInitializeCompleteState complete(CounterStateData data) => CounterInitializeCompleteState(data);

  @override
  CounterInitializeErrorState error(Object cause) => CounterInitializeErrorState(cause);
}

/// BLoC - 初期化フェーズ - 完了
class CounterInitializeCompleteState extends InitializeComplete<CounterStateData> with PhaseShiftable<CounterPostInitializedReadyState, CounterStateData> implements CounterState {
  CounterInitializeCompleteState(super.result);

  @override
  CounterPostInitializedReadyState shift() => CounterPostInitializedReadyState(result);
}

/// BLoC - 初期化フェーズ - エラー
class CounterInitializeErrorState extends InitializeError implements CounterState {
  CounterInitializeErrorState(super.exception);

  @override
  CounterInitializeReadyState ready() => CounterInitializeReadyState();
}

//////////////////////
/// 初期化完了フェーズ
//////////////////////

/// BLoC - 初期化完了フェーズ - 待機
class CounterPostInitializedReadyState extends PostInitializedStartableReady<CounterStateData> implements CounterState {
  CounterPostInitializedReadyState(super.data);

  @override
  CounterPostInitializedLoadingState start() => CounterPostInitializedLoadingState(data);
}

/// BLoC - 初期化完了フェーズ - 読込中
class CounterPostInitializedLoadingState extends PostInitializedLoading<CounterStateData> implements CounterState {
  CounterPostInitializedLoadingState(super.data);

  @override
  CounterPostInitializedCompleteState<T> complete<T>(CounterStateData data, T result) => CounterPostInitializedCompleteState<T>(data, result);

  @override
  CounterPostInitializedErrorState error(Object cause) => CounterPostInitializedErrorState(data, cause);
}

/// BLoC - 初期化完了フェーズ - 完了
class CounterPostInitializedCompleteState<T> extends PostInitializedComplete<CounterStateData, T> implements CounterState {
  CounterPostInitializedCompleteState(super.data, super.result);

  @override
  CounterPostInitializedReadyState ready() => CounterPostInitializedReadyState(data);
}

/// BLoC - 初期化完了フェーズ - エラー
class CounterPostInitializedErrorState extends PostInitializedError<CounterStateData> implements CounterState {
  CounterPostInitializedErrorState(super.data, super.cause);

  @override
  CounterPostInitializedReadyState ready() => CounterPostInitializedReadyState(data);
}
