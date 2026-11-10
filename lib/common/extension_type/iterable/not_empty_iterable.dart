import "/common/class/exception/invalid_value_exception.dart";

/// 空でないIterable
extension type NotEmptyIterable<E>._(Iterable<E> _value) implements Iterable<E> {
  factory NotEmptyIterable(Iterable<E> value) {
    final snapshot = List<E>.unmodifiable(value);
    if (snapshot.isEmpty) throw InvalidValueException(invalidValue: snapshot, message: "value must be not empty");
    return NotEmptyIterable._(snapshot);
  }
}

extension NotEmptyIterableExtension<E> on Iterable<E> {
  NotEmptyIterable<E> toNotEmpty() => NotEmptyIterable(this);
}
