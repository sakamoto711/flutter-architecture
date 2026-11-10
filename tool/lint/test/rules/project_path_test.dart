import "package:test/test.dart";
import "package:flutter_architecture_lint/rules/project_ast_visitor.dart";

void main() {
  test("Parent directory names do not disable lint", () {
    for (final root in ["/work/test/app", "/work/tool/app", "/work/lib/app"]) {
      expect(isProjectLibPath("$root/lib/domain/value.dart", root), isTrue);
      expect(isProjectLibPath("$root/test/value.dart", root), isFalse);
      expect(isProjectLibPath("$root/tool/generator/lib/value.dart", root), isFalse);
      expect(isProjectLibPath("${root}2/lib/value.dart", root), isFalse);
    }
    expect(isProjectLibPath("/work/lib/value.dart", null), isFalse);
  });
}
