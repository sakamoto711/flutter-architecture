import "package:flutter_architecture/common/class/struct/result.dart";
import "package:test/test.dart";

Never _origin() => throw Exception("original");
void main() {
  for (final async in [false, true]) {
    test("Result preserves the throwing frame (async=$async)", () async {
      final result = async ? await Result.runCatchingAsync<int>(() async => _origin()) : Result.runCatching<int>(_origin);
      try {
        result.unwrapOrThrow();
        fail("Expected failure");
      } catch (_, stack) {
        expect(stack.toString(), contains("_origin"));
      }
    });
  }
}
