import "package:analyzer_testing/analysis_rule/analysis_rule.dart";
import "package:test/test.dart";
import "package:flutter_architecture_lint/rules/avoid_relative_import_export_rule.dart";
import "package:flutter_architecture_lint/rules/project_ast_visitor.dart";

import "test_error_codes.dart";

void main() {
  group("AvoidRelativeImportExportRule", () {
    late AvoidRelativeImportExportRuleTest testHelper;

    setUp(() {
      ProjectAstVisitor.skipPathCheck = true;
      testHelper = AvoidRelativeImportExportRuleTest();
      testHelper.setUp();
    });

    tearDown(() {
      ProjectAstVisitor.skipPathCheck = false;
    });

    /// ---------- 正常系 ---------- ///

    test("[Positive] should report error for ../ relative import", () async {
      await testHelper.testParentRelativeImportShouldReportError();
    });

    test("[Positive] should report error for ./ relative import", () async {
      await testHelper.testCurrentRelativeImportShouldReportError();
    });

    test("[Positive] should report error for relative export", () async {
      await testHelper.testRelativeExportShouldReportError();
    });

    /// ---------- 異常系 ---------- ///

    test("[Negative] should not report error for absolute import", () async {
      await testHelper.testAbsoluteImportShouldNotReportError();
    });

    test("[Negative] should not report error for same directory import", () async {
      await testHelper.testSameDirectoryImportShouldNotReportError();
    });

    test("[Negative] should not report error for package import", () async {
      await testHelper.testPackageImportShouldNotReportError();
    });
  });
}

class AvoidRelativeImportExportRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidRelativeImportExportRule();
    super.setUp();
  }

  Future<void> testParentRelativeImportShouldReportError() async {
    await assertDiagnostics(
      """
import "../common/event/event.dart";

void main() {}
""",
      [error(uriDoesNotExist, 7, 28), lint(7, 28)],
    );
  }

  Future<void> testCurrentRelativeImportShouldReportError() async {
    await assertDiagnostics(
      """
import "./event.dart";

void main() {}
""",
      [error(uriDoesNotExist, 7, 14), lint(7, 14)],
    );
  }

  Future<void> testRelativeExportShouldReportError() async {
    await assertDiagnostics(
      """
export "../common/event/event.dart";

void main() {}
""",
      [error(uriDoesNotExist, 7, 28), lint(7, 28)],
    );
  }

  Future<void> testAbsoluteImportShouldNotReportError() async {
    await assertDiagnostics(
      """
import "/presentation/view/style/theme.dart";

void main() {}
""",
      [
        // URI_DOES_NOT_EXIST は出るが、ルール違反ではない
        error(uriDoesNotExist, 7, 37),
      ],
    );
  }

  Future<void> testSameDirectoryImportShouldNotReportError() async {
    await assertDiagnostics(
      """
import "event.dart";

void main() {}
""",
      [
        // URI_DOES_NOT_EXIST は出るが、ルール違反ではない
        error(uriDoesNotExist, 7, 12),
      ],
    );
  }

  Future<void> testPackageImportShouldNotReportError() async {
    await assertDiagnostics(
      """
import "package:flutter/material.dart";

void main() {}
""",
      [
        // URI_DOES_NOT_EXIST は出るが、ルール違反ではない
        error(uriDoesNotExist, 7, 31),
      ],
    );
  }
}
