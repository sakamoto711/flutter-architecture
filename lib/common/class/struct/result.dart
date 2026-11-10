import "package:meta/meta.dart";

import "/common/class/exception/exception.dart";
import "/common/extension/object_extension.dart";
import "/common/typedef/future_or_typedef.dart";

/// 実行結果
///
/// 実行結果を表現するクラスです。
///
/// [runCatching]、[runCatchingAsync]を使用することで、同期処理・非同期処理をラップすることができます。
@immutable
sealed class Result<T> {
  const Result();

  /// 処理実行(同期)
  ///
  /// [action] 実行する処理
  ///
  /// [action]を実行して成功時は[Success]、例外発生時は[Failure]を返却します。
  static Result<T> runCatching<T>(T Function() action) {
    try {
      return Success<T>(action());
    } catch (e, stackTrace) {
      return Failure(e, stackTrace);
    }
  }

  /// 処理実行(非同期)
  ///
  /// [action] 実行する処理
  ///
  /// [action]を実行して成功時は[Success]、例外発生時は[Failure]を返却します。
  static Future<Result<T>> runCatchingAsync<T>(Future<T> Function() action) async {
    try {
      return Success<T>(await action());
    } catch (e, stackTrace) {
      return Failure(e, stackTrace);
    }
  }

  /// 実行結果取得
  ///
  /// 実行結果を取得します。
  /// 自身が[Success]の場合は[value]を返却します。
  /// 自身が[Failure]の場合は[exception]を`throw`します。
  T unwrapOrThrow() => switch (this) {
    Success(value: final value) => value,
    Failure(:final exception, :final stackTrace) => Error.throwWithStackTrace(exception, stackTrace),
  };
}

/// 成功時の実行結果
///
/// 成功時の実行結果を表現するクラスです。
final class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);
}

/// 例外発生時の実行結果
///
/// 例外発生時の実行結果を表現するクラスです。
/// Dartの言語仕様で`Exception`や`Error`以外も`throw`可能なため、throwされたオブジェクトに応じて[Exception]型に変換します。
/// `throw`されたオブジェクトが[Exception]型の場合はそのまま[Exception]型として保持します。
/// `throw`されたオブジェクトが[Exception]型でない場合は、[UnexpectedThrowableException]型に変換します。
final class Failure extends Result<Never> {
  final Exception exception;
  final StackTrace stackTrace;

  Failure(Object exception, this.stackTrace) : exception = exception.asOrNull<Exception>() ?? UnexpectedThrowableException(exception);
}

extension FutureOrResultExtension<T> on FutureOr<Result<T>> {
  Future<T> unwrapOrThrow() async {
    final result = await this;
    return result.unwrapOrThrow();
  }
}
