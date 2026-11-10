import "package:meta/meta_meta.dart";

/// デシリアライズ限定
///
/// デシリアライズ時限定のフィールド・メソッドを定義するためのアノテーションです。
/// 通常時はデリゲートメソッドやgetterメソッドを用いたいが、デシリアライズ時は直接アクセスしたいという場合に使用してください。
/// CustomLintと連携して使用することを想定しています。
@Target({TargetKind.field, TargetKind.method})
class DeserializeOnly {
  const DeserializeOnly();
}

const deserializeOnly = DeserializeOnly();
