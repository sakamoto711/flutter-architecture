import "package:flutter/foundation.dart";

import "phase.dart";
import "state_data.dart";
import "status.dart";

export "phase.dart";
export "state_data.dart";
export "status.dart";

/// 状態
///
/// 処理の状態を表現します。
/// 処理の状態は[Phase]と[Status]の組み合わせで表現します。
@immutable
abstract interface class State {
  const State();
}

/// データ保持
///
/// 初期化が完了し、データを保持した状態を表現します。
/// @see [StateData]
abstract interface class DataHolding<T> implements State {
  T get data;
}

/// 初期化フェーズ - 待機
///
/// 初期化フェーズの待機状態を表現します。
/// [start]メソッドを呼び出すと[InitializeLoading]状態に遷移します。
abstract class InitializeReady implements Initialize, StartableReady<InitializeLoading<Object?>> {
  @override
  InitializeLoading<Object?> start();
}

/// 初期化フェーズ - 処理実行中
///
/// 初期化フェーズの処理実行中の状態を表現します。
/// [complete]メソッドを呼び出すと[InitializeComplete]状態に遷移します。
/// [error]メソッドを呼び出すと[InitializeError]状態に遷移します。
abstract class InitializeLoading<T> implements Initialize, Loading {
  InitializeComplete<T> complete(T data);

  @override
  InitializeError error(Object cause);
}

/// 初期化フェーズ - 処理実行完了
///
/// 初期化フェーズの処理実行完了の状態を表現します。
/// [proceed]メソッドを呼び出すと[PostInitializedReady]状態に遷移します。
abstract class InitializeComplete<T> implements Initialize, Complete<T>, DataHolding<T> {
  @override
  final T result;

  @override
  T get data => result;

  InitializeComplete(this.result);
}

/// 初期化フェーズ - 処理エラー発生
///
/// 初期化フェーズの処理でエラーが発生した状態を表現します。
/// [retry]メソッドを呼び出すと[InitializeLoading]状態に遷移します。
abstract class InitializeError with ErrorMixin implements Initialize, Error, ReadyShiftable<InitializeReady> {
  @override
  final Object cause;

  InitializeError(this.cause);

  @override
  InitializeReady ready();
}

/// 初期化完了後フェーズ - 待機
///
/// 初期化完了後のフェーズの待機状態を表現します。
/// 処理開始能力が必要な待機状態には[PostInitializedStartableReady]を使用します。
abstract class PostInitializedReady<T> implements PostInitialized<T>, Ready {
  @override
  final T data;

  PostInitializedReady(this.data);
}

/// 初期化完了後フェーズ - 処理開始可能な待機
///
/// [start]メソッドを呼び出すと[PostInitializedLoading]状態に遷移します。
abstract class PostInitializedStartableReady<T> extends PostInitializedReady<T> implements StartableReady<PostInitializedLoading<T>> {
  PostInitializedStartableReady(super.data);

  @override
  PostInitializedLoading<T> start();
}

/// 初期化完了後フェーズ - 処理実行中
///
/// 初期化完了後のフェーズの処理実行中の状態を表現します。
/// [complete]メソッドを呼び出すと[PostInitializedComplete]状態に遷移します。
/// [error]メソッドを呼び出すと[PostInitializedError]状態に遷移します。
abstract class PostInitializedLoading<T> implements PostInitialized<T>, Loading {
  @override
  final T data;

  PostInitializedLoading(this.data);

  PostInitializedComplete<T, U> next<U>(U result) => result is T ? complete(result, result) : complete(data, result);

  @protected
  PostInitializedComplete<T, U> complete<U>(T data, U result);

  @override
  PostInitializedError<T> error(Object cause);
}

/// 初期化完了後フェーズ - 処理完了
///
/// 初期化完了後のフェーズの処理完了の状態を表現します。
/// 処理結果[result]を保持します。
/// [data]と[result]が同じ型の場合、[data]を[result]に自動で代入します。
abstract class PostInitializedComplete<T, U> implements PostInitialized<T>, Complete<U>, ReadyShiftable<PostInitializedReady<T>> {
  @override
  final T data;

  @override
  final U result;

  PostInitializedComplete(this.data, this.result);

  @override
  PostInitializedReady<T> ready();
}

/// 初期化完了後フェーズ - 処理エラー発生
///
/// 初期化完了後のフェーズの処理でエラーが発生した状態を表現します。
/// [retry]メソッドを呼び出すと[PostInitializedLoading]状態に遷移します。
abstract class PostInitializedError<T> with ErrorMixin implements PostInitialized<T>, Error, ReadyShiftable<PostInitializedReady<T>> {
  @override
  final T data;

  @override
  final Object cause;

  PostInitializedError(this.data, this.cause);

  @override
  PostInitializedReady<T> ready();
}
