import "logger.dart";

/// ログ出力先を持たないサンプル・テスト用Logger。
class NoopLogger implements Logger {
  const NoopLogger();
  @override
  void debug({String? message, Object? error, StackTrace? stackTrace, Context? context}) {}
  @override
  void info({String? message, Object? error, StackTrace? stackTrace, Context? context}) {}
  @override
  void warning({String? message, Object? error, StackTrace? stackTrace, Context? context}) {}
  @override
  void notice({String? message, Object? error, StackTrace? stackTrace, Context? context}) {}
  @override
  void error({String? message, Object? error, StackTrace? stackTrace, Context? context}) {}
  @override
  void critical({String? message, Object? error, StackTrace? stackTrace, Context? context}) {}
  @override
  void alert({String? message, Object? error, StackTrace? stackTrace, Context? context}) {}
  @override
  void emergency({String? message, Object? error, StackTrace? stackTrace, Context? context}) {}
}
