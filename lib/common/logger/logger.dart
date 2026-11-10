import "package:meta/meta.dart";

abstract interface class Logger {
  void debug({String? message, Object? error, StackTrace? stackTrace, Context? context});
  void info({String? message, Object? error, StackTrace? stackTrace, Context? context});
  void warning({String? message, Object? error, StackTrace? stackTrace, Context? context});
  void notice({String? message, Object? error, StackTrace? stackTrace, Context? context});
  void error({String? message, Object? error, StackTrace? stackTrace, Context? context});
  void critical({String? message, Object? error, StackTrace? stackTrace, Context? context});
  void alert({String? message, Object? error, StackTrace? stackTrace, Context? context});
  void emergency({String? message, Object? error, StackTrace? stackTrace, Context? context});
}

@immutable
extension type const Context(Map<String, dynamic> _value) {
  factory Context.single(String key, dynamic value) => Context({key: value});
}
