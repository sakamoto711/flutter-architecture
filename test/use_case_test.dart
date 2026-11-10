import "dart:async";

import "package:flutter_architecture/application/use_case.dart";
import "package:flutter_architecture/common/class/exception/exception.dart";
import "package:flutter_architecture/common/logger/noop_logger.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("検証失敗ではqueryを呼ばず、onErrorに通知する", () async {
    var executed = false;
    final query = _Query(() {
      executed = true;
      return 1;
    });
    final result = await InputPortInvoker(query).invoke(_Parameter(Exception("invalid")));
    expect(result, isA<Failure>());
    expect(executed, isFalse);
  });

  test("同期と非同期の実行結果を取得できる", () async {
    expect(await InputPortInvoker(_Query(() => 2)).invoke(const _Parameter()).unwrapOrThrow(), 2);
    expect(await InputPortInvoker(_Query(() async => 3)).invoke(const _Parameter()).unwrapOrThrow(), 3);
  });

  test("ErrorをExceptionに包んで返す", () async {
    final result = await InputPortInvoker(_Query(() => throw StateError("broken"))).invoke(const _Parameter());
    expect(result, isA<Failure>().having((failure) => failure.exception, "exception", isA<UnexpectedThrowableException>()));
  });

  test("onSuccessの失敗をonErrorへ二重通知しない", () async {
    final output = _ThrowingOutput();
    await expectLater(_Query(() => 1).perform(const _Parameter(), output), throwsStateError);
    expect(output.errorCalls, 0);
  });
}

class _Parameter extends InputPortParameter {
  final Exception? error;
  const _Parameter([this.error]);
  @override
  void validate() {
    if (error case final error?) throw error;
  }

  @override
  List<Object?> get props => [error];
}

class _Query extends Query<_Parameter, int> {
  final FutureOr<int> Function() action;
  const _Query(this.action) : super(logger: const NoopLogger());
  @override
  FutureOr<int> query(_Parameter param) => action();
}

class _ThrowingOutput implements OutputPort<int> {
  var errorCalls = 0;
  @override
  Future<void> onSuccess(int result) async => throw StateError("output failed");
  @override
  void onError(Exception e) {
    errorCalls++;
  }
}
