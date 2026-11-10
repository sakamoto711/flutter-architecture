import "package:flutter/foundation.dart";

import "state.dart";

/// 状態不正例外
///
/// 実際の`State`と期待する`State`が一致しない場合に発生する例外
@immutable
class IllegalStateException implements Exception {
  final State actual; // 実際の状態
  final Type expected; // 期待する状態

  const IllegalStateException({
    required this.actual,
    required this.expected,
  });

  @override
  String toString() => "IllegalStateException: Expected is $expected, but actual is $actual";
}

/// Ready変更不可例外
///
/// Ready変更可能な`State`が渡された場合に発生する例外
@immutable
final class NotReadyShiftableException extends IllegalStateException {
  final State state;

  const NotReadyShiftableException({
    required this.state,
  }) : super(actual: state, expected: Ready);

  @override
  String toString() => "NotReadyShiftableException: State is $state";
}

/// 状態データ不正例外
///
/// 実際の`StateData`と期待する`StateData`が一致しない場合に発生する例外
@immutable
class IllegalStateDataException implements Exception {
  final StateData actual;
  final Type expected;

  const IllegalStateDataException({
    required this.actual,
    required this.expected,
  });

  @override
  String toString() => "IllegalStateDataException: Expected is $expected, but actual is $actual";
}

/// Event handlerがLoading状態を残して終了した場合に発生する例外
@immutable
final class EventHandlerCompletedInLoadingException implements Exception {
  final Type eventType;

  const EventHandlerCompletedInLoadingException({required this.eventType});

  @override
  String toString() => "EventHandlerCompletedInLoadingException: $eventType left the state Loading";
}
