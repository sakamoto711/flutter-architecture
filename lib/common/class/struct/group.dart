import "package:equatable/equatable.dart";
import "package:meta/meta.dart";

import "/common/extension/object_extension.dart";
import "/common/extension_type/iterable/not_empty_iterable.dart";

/// グループ
///
/// グループを表現します。
/// グループには1件または複数件の要素が含まれます。
///
/// * [EmptyGroup] : 要素を保持しない
/// * [SingleGroup] : 1件の要素を保持
/// * [MultipleGroup] : 複数件の要素を保持
///
/// 使用例:
/// ```dart
/// Group<Menu> menuGroup = Group.empty();
/// Group<Menu> menuGroup = Group.single(menu);
/// Group<Menu> menuGroup = Group.from(menuList);
/// ValuedGroup<Menu> menuGroup = ValuedGroup.from(menuList);
/// ```
@immutable
sealed class Group<T extends Object> with EquatableMixin {
  const Group();

  factory Group.from(Iterable<T> values) {
    final snapshot = List<T>.unmodifiable(values);
    return switch (snapshot.length) {
      0 => EmptyGroup<T>(),
      1 => SingleGroup<T>(snapshot.first),
      _ => MultipleGroup<T>._(snapshot),
    };
  }

  factory Group.empty() => EmptyGroup<T>();

  factory Group.single(T value) => SingleGroup(value);

  Group<T> merge({required Group<T> other, bool distinct = false});

  Iterable<T> get values;
}

/// 空グループ
///
/// 要素を保持しません。
final class EmptyGroup<T extends Object> extends Group<T> {
  const EmptyGroup();

  @override
  Group<T> merge({required Group<T> other, bool distinct = false}) => distinct ? Group.from(other.values.toSet()) : other;

  @override
  Iterable<T> get values => [];

  @override
  List<Object?> get props => [];
}

sealed class ValuedGroup<T extends Object> extends Group<T> {
  const ValuedGroup();

  factory ValuedGroup.from(NotEmptyIterable<T> values) => switch (values.length) {
    1 => SingleGroup(values.first),
    _ => MultipleGroup._(values),
  };

  @override
  NotEmptyIterable<T> get values;

  @override
  List<Object?> get props => [...values];
}

/// 単一グループ
///
/// 単一の要素を保持します。
final class SingleGroup<T extends Object> extends ValuedGroup<T> {
  @override
  List<Object?> get props => [value];

  final T value;

  const SingleGroup(this.value);

  @override
  ValuedGroup<T> merge({required Group<T> other, bool distinct = false}) => switch (distinct) {
    true => switch (other) {
      EmptyGroup() => this,
      SingleGroup() => value == other.value ? this : MultipleGroup._({value, other.value}),
      MultipleGroup() => ValuedGroup.from({value, ...other.values}.toNotEmpty()),
    },
    false => switch (other) {
      EmptyGroup() => this,
      SingleGroup() => MultipleGroup._([value, other.value]),
      MultipleGroup() => MultipleGroup._([value, ...other.values]),
    },
  };

  @override
  NotEmptyIterable<T> get values => NotEmptyIterable([value]);
}

/// 複数グループ
///
/// 複数の要素を保持します。
final class MultipleGroup<T extends Object> extends ValuedGroup<T> {
  @override
  List<Object?> get props => [...values];

  @override
  final NotEmptyIterable<T> values;

  MultipleGroup._(Iterable<T> values) : values = NotEmptyIterable(values);

  @override
  ValuedGroup<T> merge({required Group<T> other, bool distinct = false}) => switch (distinct) {
    true => switch (other) {
      EmptyGroup() => values.toSet().let((it) => it.length == 1 ? SingleGroup(it.first) : MultipleGroup._(it)),
      SingleGroup() => ValuedGroup.from({...values, other.value}.toNotEmpty()),
      MultipleGroup() => ValuedGroup.from({...values, ...other.values}.toNotEmpty()),
    },
    false => switch (other) {
      EmptyGroup() => this,
      SingleGroup() => MultipleGroup._([...values, other.value]),
      MultipleGroup() => MultipleGroup._([...values, ...other.values]),
    },
  };
}
