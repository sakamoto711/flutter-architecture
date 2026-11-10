import "package:analyzer_testing/analysis_rule/analysis_rule.dart";
import "package:test/test.dart";
import "package:flutter_architecture_lint/rules/avoid_unnecessary_explicit_type_rule.dart";
import "package:flutter_architecture_lint/rules/project_ast_visitor.dart";

void main() {
  group("AvoidUnnecessaryExplicitTypeRule", () {
    late AvoidUnnecessaryExplicitTypeRuleTest testHelper;

    setUp(() {
      ProjectAstVisitor.skipPathCheck = true;
      testHelper = AvoidUnnecessaryExplicitTypeRuleTest();
      testHelper.setUp();
    });

    tearDown(() {
      ProjectAstVisitor.skipPathCheck = false;
    });

    test("[Negative] retains explicit closure parameter types without external context", () async {
      await testHelper.assertNoDiagnostics("""
void main() {
  final transform = (int value) => value + 1;
  print(transform(1));
}
""");
    });

    test("[Negative] conservatively retains typed callback parameters", () async {
      await testHelper.assertNoDiagnostics("""
void accept(int Function(int) transform) {}
void main() {
  accept((int value) => value + 1);
}
""");
    });

    test("[Negative] retains contextual collection and generic types", () async {
      await testHelper.assertNoDiagnostics("""
class Box<T> { Box(); }
void main() {
  final List<int> values = [];
  final Set<int> unique = {};
  final Box<int> box = Box();
  final double coerced = 1;
  final List<int> first = <int>[], second = [];
  print([values, unique, box, coerced, first, second]);
}
""");
    });

    test("[Negative] retains for-in declarations without final or var", () async {
      await testHelper.assertNoDiagnostics("""
void main() {
  final values = <int>[1];
  for (int value in values) { print(value); }
}
""");
    });

    /// ---------- 正常系: ローカル変数 ---------- ///

    test("[Positive] should report error for unnecessary type in final variable", () async {
      await testHelper.testUnnecessaryTypeInFinalVariable();
    });

    /// ---------- 正常系: for-inループ ---------- ///

    test("[Positive] should report error for unnecessary type in for-in loop", () async {
      await testHelper.testUnnecessaryTypeInForInLoop();
    });

    /// ---------- 異常系 ---------- ///

    test("[Negative] should not report error when type is needed", () async {
      await testHelper.testTypeNeededShouldNotReportError();
    });

    test("[Negative] should not report error for function type", () async {
      await testHelper.testFunctionTypeShouldNotReportError();
    });

    test("[Negative] should not report error when no initializer", () async {
      await testHelper.testNoInitializerShouldNotReportError();
    });

    test("[Negative] should not report error for function declaration return type", () async {
      await testHelper.testFunctionDeclarationShouldNotReportError();
    });

    test("[Negative] should not report error for function declaration parameter type", () async {
      await testHelper.testFunctionDeclarationParameterShouldNotReportError();
    });
  });
}

class AvoidUnnecessaryExplicitTypeRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidUnnecessaryExplicitTypeRule();
    super.setUp();
  }

  Future<void> testUnnecessaryTypeInFinalVariable() async {
    await assertDiagnostics(
      """
void main() {
  final String a = "test";
}
""",
      [lint(22, 6)],
    );
  }

  Future<void> testUnnecessaryTypeInForInLoop() async {
    await assertDiagnostics(
      """
void main() {
  final list = <String>["a", "b", "c"];
  for (final String item in list) {
    print(item);
  }
}
""",
      [lint(67, 6)],
    );
  }

  Future<void> testTypeNeededShouldNotReportError() async {
    await assertNoDiagnostics("""
void main() {
  final num a = 42;  // int を num として扱いたい
}
""");
  }

  Future<void> testFunctionTypeShouldNotReportError() async {
    await assertNoDiagnostics("""
void main() {
  final void Function() callback = () {};
}
""");
  }

  Future<void> testNoInitializerShouldNotReportError() async {
    await assertNoDiagnostics("""
class Foo {
  final String value;
  Foo(this.value);
}
""");
  }

  Future<void> testFunctionDeclarationShouldNotReportError() async {
    await assertNoDiagnostics("""
String getValue() => "test";
""");
  }

  Future<void> testFunctionDeclarationParameterShouldNotReportError() async {
    await assertNoDiagnostics("""
String getValue(String input) => input;
""");
  }
}
