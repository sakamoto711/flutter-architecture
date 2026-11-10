import "package:flutter_architecture/application/use_case.dart";
import "package:flutter_architecture/common/logger/noop_logger.dart";
import "package:test/test.dart";

Never _throwAtOrigin() => throw Exception("original");

class _Parameter extends InputPortParameter {
  const _Parameter();
  @override
  void validate() {}
  @override
  List<Object?> get props => [];
}

class _Query extends Query<_Parameter, int> {
  const _Query() : super(logger: const NoopLogger());
  @override
  int query(_Parameter parameter) => _throwAtOrigin();
}

void main() {
  test("UseCase OutputPort Result and rethrow retain the origin", () async {
    final result = await const InputPortInvoker(_Query()).invoke(const _Parameter());
    try {
      result.unwrapOrThrow();
      fail("Expected failure");
    } catch (_, stack) {
      expect(stack.toString(), contains("_throwAtOrigin"));
    }
  });
}
