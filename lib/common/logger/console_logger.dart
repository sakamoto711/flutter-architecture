import "dart:developer" as developer;

import "logger.dart";

class ConsoleLogger implements Logger {
  const ConsoleLogger();
  @override
  void debug({String? message, Object? error, StackTrace? stackTrace, Context? context}) => developer.log(message ?? "", error: error, stackTrace: stackTrace);
  @override
  void info({String? message, Object? error, StackTrace? stackTrace, Context? context}) => debug(message: message, error: error, stackTrace: stackTrace, context: context);
  @override
  void warning({String? message, Object? error, StackTrace? stackTrace, Context? context}) => debug(message: message, error: error, stackTrace: stackTrace, context: context);
  @override
  void notice({String? message, Object? error, StackTrace? stackTrace, Context? context}) => debug(message: message, error: error, stackTrace: stackTrace, context: context);
  @override
  void error({String? message, Object? error, StackTrace? stackTrace, Context? context}) => developer.log("${message ?? ''} ${context ?? ''}", level: 1000, error: error, stackTrace: stackTrace);
  @override
  void critical({String? message, Object? error, StackTrace? stackTrace, Context? context}) => this.error(message: message, error: error, stackTrace: stackTrace, context: context);
  @override
  void alert({String? message, Object? error, StackTrace? stackTrace, Context? context}) => this.error(message: message, error: error, stackTrace: stackTrace, context: context);
  @override
  void emergency({String? message, Object? error, StackTrace? stackTrace, Context? context}) => this.error(message: message, error: error, stackTrace: stackTrace, context: context);
}
