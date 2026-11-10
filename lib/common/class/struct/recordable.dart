import "package:equatable/equatable.dart";
import "package:flutter/foundation.dart";

import "/common/class/annotation/ignore_props_check.dart";
import "/common/extension_type/iterable/not_empty_iterable.dart";

abstract interface class Recordable {}

/// 複数値保持機構
///
/// Kotlinの`Pair`のイメージです。
/// 必ずN個の値を保持するという制約を実現したい場合に利用してください。
/// Dart3.0から用意されたRecord構文と互助関係にあります。
@immutable
sealed class Record with EquatableMixin implements Recordable {
  const Record();
}

/// 複数値保持機構(2個)
class Tuple<S, T> extends Record {
  final S first;
  final T second;

  const Tuple(this.first, this.second);

  (S, T) toRecordType() => (first, second);

  @override
  List<Object?> get props => [first, second];
}

/// 複数値保持機構(3個)
class Triple<S, T, U> extends Record {
  final S first;
  final T second;
  final U third;

  const Triple(this.first, this.second, this.third);

  (S, T, U) toRecordType() => (first, second, third);

  @override
  List<Object?> get props => [first, second, third];
}

/// 複数値保持機構(4個)
class Quadruple<S, T, U, V> extends Record {
  final S first;
  final T second;
  final U third;
  final V fourth;

  const Quadruple(this.first, this.second, this.third, this.fourth);

  (S, T, U, V) toRecordType() => (first, second, third, fourth);

  @override
  List<Object?> get props => [first, second, third, fourth];
}

/// 複数値保持機構(5個)
class Quintuple<S, T, U, V, W> extends Record {
  final S first;
  final T second;
  final U third;
  final V fourth;
  final W fifth;

  const Quintuple(this.first, this.second, this.third, this.fourth, this.fifth);

  (S, T, U, V, W) toRecordType() => (first, second, third, fourth, fifth);

  @override
  List<Object?> get props => [first, second, third, fourth, fifth];
}

/// 型制約付き複数値保持機構
///
/// [Record]型に上限型制約を設けたクラスです。
/// 保持する値が必ず`E`型を継承したクラスの場合に使用してください。
@immutable
@ignorePropsCheck
sealed class TypedRecord<E> with EquatableMixin implements Recordable {
  const TypedRecord();

  NotEmptyIterable<E> get values;
}

/// 型制約付き複数値保持機構(2個)
class TypedTuple<E, S extends E, T extends E> extends TypedRecord<E> {
  final S first;
  final T second;

  const TypedTuple(this.first, this.second);

  (S, T) toRecordType() => (first, second);

  @override
  NotEmptyIterable<E> get values => [first, second].toNotEmpty();

  @override
  List<Object?> get props => [...values];
}

/// 型制約付き複数値保持機構(3個)
class TypedTriple<E, S extends E, T extends E, U extends E> extends TypedRecord<E> {
  final S first;
  final T second;
  final U third;

  const TypedTriple(this.first, this.second, this.third);

  (S, T, U) toRecordType() => (first, second, third);

  @override
  NotEmptyIterable<E> get values => [first, second, third].toNotEmpty();

  @override
  List<Object?> get props => [...values];
}

/// 型制約付き複数値保持機構(4個)
class TypedQuadruple<E, S extends E, T extends E, U extends E, V extends E> extends TypedRecord<E> {
  final S first;
  final T second;
  final U third;
  final V fourth;

  const TypedQuadruple(this.first, this.second, this.third, this.fourth);

  (S, T, U, V) toRecordType() => (first, second, third, fourth);

  @override
  NotEmptyIterable<E> get values => [first, second, third, fourth].toNotEmpty();

  @override
  List<Object?> get props => [...values];
}

/// 型制約付き複数値保持機構(5個)
class TypedQuintuple<E, S extends E, T extends E, U extends E, V extends E, W extends E> extends TypedRecord<E> {
  final S first;
  final T second;
  final U third;
  final V fourth;
  final W fifth;

  const TypedQuintuple(this.first, this.second, this.third, this.fourth, this.fifth);

  (S, T, U, V, W) toRecordType() => (first, second, third, fourth, fifth);

  @override
  NotEmptyIterable<E> get values => [first, second, third, fourth, fifth].toNotEmpty();

  @override
  List<Object?> get props => [...values];
}

extension TupleExtension<S, T> on (S, T) {
  Tuple<S, T> toTuple() => Tuple($1, $2);
}

extension TripleExtension<S, T, U> on (S, T, U) {
  Triple<S, T, U> toTriple() => Triple($1, $2, $3);
}

extension QuadrupleExtension<S, T, U, V> on (S, T, U, V) {
  Quadruple<S, T, U, V> toQuadruple() => Quadruple($1, $2, $3, $4);
}

extension QuintupleExtension<S, T, U, V, W> on (S, T, U, V, W) {
  Quintuple<S, T, U, V, W> toQuintuple() => Quintuple($1, $2, $3, $4, $5);
}
