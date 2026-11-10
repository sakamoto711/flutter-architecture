import "package:meta/meta_meta.dart";

/// Equatableのpropsチェックを無視
///
/// このアノテーションが付与されたクラスは、`missing_field_in_props` Lintルールの対象外となります。
/// 継承先のクラスも同様に除外されます。
///
/// 使用例:
/// ```dart
/// @IgnorePropsCheck()
/// class OptionItem<K> with EquatableMixin {
///   final K key;
///   final Object _value;
///
///   @override
///   List<Object?> get props => [key]; // _valueが含まれていなくても警告なし
/// }
/// ```
@Target({TargetKind.classType})
class IgnorePropsCheck {
  const IgnorePropsCheck();
}

const ignorePropsCheck = IgnorePropsCheck();
