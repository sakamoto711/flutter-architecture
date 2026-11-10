import "package:analyzer_testing/analysis_rule/analysis_rule.dart";
import "package:flutter_architecture_lint/rules/missing_field_in_props_rule.dart";
import "package:flutter_architecture_lint/rules/project_ast_visitor.dart";
import "package:test/test.dart";

void main() {
  setUp(() {
    MissingFieldInPropsRule.skipEquatablePackageCheck = true;
    ProjectAstVisitor.skipPathCheck = true;
  });
  tearDown(() {
    MissingFieldInPropsRule.skipEquatablePackageCheck = false;
    ProjectAstVisitor.skipPathCheck = false;
  });
  test("New fields must override inherited props", () async {
    await (_PropsTest()..setUp()).check(false);
  });
  test("Explicit props compares the new field", () async {
    await (_PropsTest()..setUp()).check(true);
  });
  test("Spread fields participate in equality", () async {
    await (_PropsTest()..setUp()).checkSpread();
  });
  test("Abstract classes can delegate props to concrete subclasses", () async {
    await (_PropsTest()..setUp()).checkAbstract();
  });
}

class _PropsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = MissingFieldInPropsRule();
    super.setUp();
  }

  Future<void> check(bool overrideProps) async {
    final code =
        """
abstract class Equatable { List<Object?> get props; }
class Base extends Equatable { @override List<Object?> get props => []; }
class Child extends Base {
  final int value = 1;
  ${overrideProps ? '@override List<Object?> get props => [value];' : ''}
}
""";
    if (overrideProps) {
      await assertNoDiagnostics(code);
    } else {
      await assertDiagnostics(code, [lint(code.indexOf("value ="), 9)]);
    }
  }

  Future<void> checkSpread() async {
    await assertNoDiagnostics("""
abstract class Equatable { List<Object?> get props; }
class Values extends Equatable {
  final List<int> values = [];
  @override List<Object?> get props => [...values];
}
""");
  }

  Future<void> checkAbstract() async {
    await assertNoDiagnostics("""
abstract class Equatable { List<Object?> get props; }
abstract class Base extends Equatable { final int value = 1; }
class Child extends Base { @override List<Object?> get props => [value]; }
""");
  }
}
