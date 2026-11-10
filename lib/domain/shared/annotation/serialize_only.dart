import "package:meta/meta_meta.dart";

/// シリアライズ限定
///
/// シリアライズ時限定のコンストラクタ・factoryメソッドを定義するためのアノテーションです。
/// 通常時は特定のフィールドを指定させたくないが、シリアライズ時には全て値を指定する必要があるという場合に使用してください。
/// CustomLintと連携して使用することを想定しています。
@Target({TargetKind.constructor})
class SerializeOnly {
  const SerializeOnly();
}

const serializeOnly = SerializeOnly();
