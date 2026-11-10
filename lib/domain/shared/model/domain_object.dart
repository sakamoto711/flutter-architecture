import "package:equatable/equatable.dart";
import "package:meta/meta.dart";

import "/common/class/annotation/ignore_props_check.dart";
import "identifier.dart";

export "/domain/shared/annotation/deserialize_only.dart";
export "/domain/shared/annotation/serialize_only.dart";
export "identifier.dart";

/// ドメインオブジェクト
///
/// ドメインオブジェクトを表現します。
/// 不変であることを保証してください。
@immutable
abstract interface class DomainObject {
  const DomainObject();
}

/// エンティティ
///
/// 識別子を持つオブジェクトを表現します。
/// 識別子により等価性を保証出来るように実装してください。
@ignorePropsCheck
@immutable
abstract class Entity<ID extends Identifier> with EquatableMixin implements DomainObject {
  /// 識別子
  final ID identifier;

  const Entity(this.identifier);

  @override
  @nonVirtual
  List<Object?> get props => [identifier];
}

/// 識別可能オブジェクト
///
/// [Entity]を参照してください。
typedef Identifiable<ID extends Identifier> = Entity<ID>;

/// 値オブジェクト
///
/// 値オブジェクトを表現します。
/// 全てのプロパティを用いて等等価性を保証出来るように実装してください。
@immutable
abstract class ValueObject with EquatableMixin implements DomainObject {
  const ValueObject();

  @override
  List<Object?> get props;
}

/// 識別不可オブジェクト
///
/// [ValueObject]を参照してください。
typedef Unidentifiable = ValueObject;
