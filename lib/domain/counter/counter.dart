import "/domain/shared/model/domain_object.dart";

/// サンプルで扱うカウンター値。
final class Counter extends ValueObject {
  final int value;

  const Counter(this.value);

  Counter increment() => Counter(value + 1);

  @override
  List<Object?> get props => [value];
}
