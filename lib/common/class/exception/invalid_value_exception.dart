import "package:flutter/foundation.dart";

/// 値不正例外
///
/// 値が指定された要件を満たさなかった場合にthrowする例外です。
@immutable
class InvalidValueException<T> implements Exception {
  final T invalidValue;
  final String message;

  const InvalidValueException({
    required this.invalidValue,
    required this.message,
  });

  @override
  String toString() => "${runtimeType.toString()}: $message, but was $invalidValue.";
}

class InvalidEmptyIterableException<E> extends InvalidValueException<Iterable<E>> {
  const InvalidEmptyIterableException(Iterable<E> invalidValue) : super(invalidValue: invalidValue, message: "value must be not empty");
}

/// 最大値超過例外
class InvalidMaximumValueException extends InvalidValueException<num> {
  final num maximum;

  const InvalidMaximumValueException({
    required super.invalidValue,
    required this.maximum,
  }) : super(message: "value must be $maximum or less");
}

/// 正の整数例外
class InvalidPositiveIntException extends InvalidValueException<int> {
  const InvalidPositiveIntException(int invalidValue) : super(invalidValue: invalidValue, message: "value must be positive");
}

/// 0以上の整数例外
class InvalidZeroOrPositiveIntException extends InvalidValueException<int> {
  const InvalidZeroOrPositiveIntException(int invalidValue) : super(invalidValue: invalidValue, message: "value must be 0 or more");
}

/// 正の小数例外
class InvalidPositiveDoubleException extends InvalidValueException<double> {
  const InvalidPositiveDoubleException(double invalidValue) : super(invalidValue: invalidValue, message: "value must be positive");
}

/// 0以上の小数例外
class InvalidZeroOrPositiveDoubleException extends InvalidValueException<double> {
  const InvalidZeroOrPositiveDoubleException(double invalidValue) : super(invalidValue: invalidValue, message: "value must be 0 or more");
}
