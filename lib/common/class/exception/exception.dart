import "package:flutter/foundation.dart";

/// 予期しないThrowable例外
///
/// この例外は、通常`Exception`型が期待される状況で、`Exception`型以外がスローされた場合に使用されます。
/// (主に`catch`ブロック内で `catch`した内容が`Exception`では無かった場合にスローされることを想定)
@immutable
class UnexpectedThrowableException implements Exception {
  final Object? original;

  const UnexpectedThrowableException(this.original);
  @override
  String toString() => "UnexpectedThrowableException: $original";
}

/// 予期しない null 例外
///
/// この例外は、本来 null ではないと期待される値が null であった場合にスローされます。
@immutable
class UnexpectedNullException implements Exception {
  final String message;

  const UnexpectedNullException(this.message);

  @override
  String toString() => "UnexpectedNullException: $message";
}
