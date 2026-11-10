import "package:analyzer_testing/analysis_rule/analysis_rule.dart";
import "package:test/test.dart";
import "package:flutter_architecture_lint/rules/avoid_null_force_unwrap_rule.dart";
import "package:flutter_architecture_lint/rules/project_ast_visitor.dart";

void main() {
  group("AvoidNullForceUnwrapRule", () {
    late AvoidNullForceUnwrapRuleTest testHelper;

    setUp(() {
      // テスト環境ではパスチェックをスキップ
      ProjectAstVisitor.skipPathCheck = true;
      testHelper = AvoidNullForceUnwrapRuleTest();
      testHelper.setUp();
    });

    tearDown(() {
      ProjectAstVisitor.skipPathCheck = false;
    });

    test("should report error for force unwrap", () async {
      await testHelper.testForceUnwrapShouldReportError();
    });

    test("should not report error when no force unwrap", () async {
      await testHelper.testNoForceUnwrapShouldNotReportError();
    });
  });
}

class AvoidNullForceUnwrapRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidNullForceUnwrapRule();
    super.setUp();
  }

  Future<void> testForceUnwrapShouldReportError() async {
    await assertDiagnostics(
      """
void main() {
  String? value;
  print(value!);
}
""",
      [lint(39, 6)],
    );
  }

  Future<void> testNoForceUnwrapShouldNotReportError() async {
    await assertNoDiagnostics("""
void main() {
  String value = "test";
  print(value);
}
""");
  }
}
