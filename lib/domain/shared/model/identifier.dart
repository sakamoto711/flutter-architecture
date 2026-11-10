import "package:equatable/equatable.dart";
import "package:meta/meta.dart";

import "/common/class/struct/recordable.dart";

export "identifier_group.dart";

/// 識別子
@immutable
sealed class Identifier<K extends Object> with EquatableMixin {
  final K key;

  const Identifier(this.key);

  @override
  @nonVirtual
  bool get stringify => true;

  @override
  List<Object?> get props => [key];
}

/// 単一キー
///
/// 単一の値から構成される識別子を表現します。
abstract class SingleKey<K extends Object> extends Identifier<K> {
  const SingleKey(super.key);
}

/// 複合キー
///
/// 複数の値から構成される識別子を表現します。
sealed class CompositeKey<R extends Record> extends Identifier<R> {
  const CompositeKey(super.key);
}

/// 二重キー
///
/// 二つの値から構成される識別子を表現します。
abstract class DoubleCompositeKey<S extends Object, T extends Object> extends CompositeKey<Tuple<S, T>> {
  S get first => key.first;
  T get second => key.second;

  DoubleCompositeKey(S first, T second) : super(Tuple(first, second));
}

/// 三重キー
///
/// 三つの値から構成される識別子を表現します。
abstract class TripleCompositeKey<S extends Object, T extends Object, U extends Object> extends CompositeKey<Triple<S, T, U>> {
  S get first => key.first;
  T get second => key.second;
  U get third => key.third;

  TripleCompositeKey(S first, T second, U third) : super(Triple(first, second, third));
}
