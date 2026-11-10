extension ObjectExtension<S> on S {
  /// T型へのキャスト
  ///
  /// 自身がT型の場合、そのまま自身を返却する
  /// それ以外の場合、`null`を返却する
  T? asOrNull<T>() => this is T ? this as T : null;

  /// Kotlinの`let`相当
  ///
  /// `apply`や`also`相当のことをしたい場合はカスケード演算子を利用してください
  T let<T>(T Function(S it) let) => let(this);
}
