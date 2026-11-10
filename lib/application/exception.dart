/// アプリケーション例外
///
/// アプリケーション層で発生する例外の基底クラスです。
abstract interface class ApplicationException implements Exception {}

/// 入力パラメータの検証に失敗した場合に発生する例外
///
/// 入力パラメータの検証に失敗した場合に発生する例外です。
abstract interface class ValidationException implements ApplicationException {}
