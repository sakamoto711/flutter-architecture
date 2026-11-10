import "package:analyzer_testing/analysis_rule/analysis_rule.dart";
import "package:test/test.dart";
import "package:flutter_architecture_lint/rules/missing_build_context_in_screen_event_handler_rule.dart";
import "package:flutter_architecture_lint/rules/project_ast_visitor.dart";

void main() {
  group("MissingBuildContextInScreenEventHandlerRule", () {
    late MissingBuildContextInScreenEventHandlerRuleTest testHelper;

    setUp(() {
      ProjectAstVisitor.skipPathCheck = true;
      MissingBuildContextInScreenEventHandlerRule.skipScreenPathCheck = true;
      testHelper = MissingBuildContextInScreenEventHandlerRuleTest();
      testHelper.setUp();
    });

    tearDown(() {
      ProjectAstVisitor.skipPathCheck = false;
      MissingBuildContextInScreenEventHandlerRule.skipScreenPathCheck = false;
    });

    test("[Positive] should report error for private event handler without BuildContext", () async {
      await testHelper.testPrivateEventHandlerWithoutBuildContextShouldReportError();
    });

    test("[Positive] should report error for public event handler without BuildContext", () async {
      await testHelper.testPublicEventHandlerWithoutBuildContextShouldReportError();
    });

    test("[Negative] should not report error when BuildContext exists", () async {
      await testHelper.testBuildContextIncludedShouldNotReportError();
    });

    test("[Negative] should not report error for non-event handler method", () async {
      await testHelper.testNonEventHandlerShouldNotReportError();
    });
  });
}

class MissingBuildContextInScreenEventHandlerRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = MissingBuildContextInScreenEventHandlerRule();
    super.setUp();
  }

  Future<void> testPrivateEventHandlerWithoutBuildContextShouldReportError() async {
    await assertDiagnostics(
      """
class Sample {
  void _onTapSave() {}
}
""",
      [lint(17, 20)],
    );
  }

  Future<void> testPublicEventHandlerWithoutBuildContextShouldReportError() async {
    await assertDiagnostics(
      """
class Sample {
  void onTapSave(String value) {}
}
""",
      [lint(17, 31)],
    );
  }

  Future<void> testBuildContextIncludedShouldNotReportError() async {
    await assertNoDiagnostics("""
class BuildContext {}

class Sample {
  void _onTapSave(String value, BuildContext context) {}
}
""");
  }

  Future<void> testNonEventHandlerShouldNotReportError() async {
    await assertNoDiagnostics("""
class Sample {
  void handleTap() {}
}
""");
  }
}
