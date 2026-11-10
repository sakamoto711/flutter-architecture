import "/common/class/struct/group.dart";
import "identifier.dart";

/// Identifierグループ
/// Identifier1件または複数件を透過的に扱うことを目的としています。
///
/// 詳細は[Group]を参照してください。
typedef IdentifierGroup<I extends Identifier<Object>> = Group<I>;

/// 単一識別子
typedef SingleIdentifier<I extends Identifier<Object>> = SingleGroup<I>;

/// 複数識別子
typedef MultipleIdentifier<I extends Identifier<Object>> = MultipleGroup<I>;
