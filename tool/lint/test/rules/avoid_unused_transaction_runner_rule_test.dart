import "package:analyzer/error/error.dart";
import "package:analyzer_testing/analysis_rule/analysis_rule.dart";
import "package:test/test.dart";
import "package:flutter_architecture_lint/rules/avoid_unused_transaction_runner_rule.dart";
import "package:flutter_architecture_lint/rules/project_ast_visitor.dart";

void main() {
  group("AvoidUnusedTransactionRunnerRule", () {
    late AvoidUnusedTransactionRunnerRuleTest testHelper;

    setUp(() {
      ProjectAstVisitor.skipPathCheck = true;
      testHelper = AvoidUnusedTransactionRunnerRuleTest();
      testHelper.setUp();
    });

    tearDown(() {
      ProjectAstVisitor.skipPathCheck = false;
    });

    test("[Positive] reports an error when a UseCase does not use an injected TransactionRunner", () async {
      await testHelper.testUnusedTransactionRunnerShouldReportError();
    });

    test("[Positive] reports an error for an indirect UseCase subtype", () async {
      await testHelper.testUnusedTransactionRunnerInCommandShouldReportError();
    });

    test("[Positive] reports an error for a type parameter bounded by TransactionRunner", () async {
      await testHelper.testUnusedBoundedTransactionRunnerShouldReportError();
    });

    test("[Positive] reports only the unused TransactionRunner when a UseCase injects multiple runners", () async {
      await testHelper.testOnlyUnusedTransactionRunnerShouldReportError();
    });

    test("[Positive] does not count an explicit constructor initializer as TransactionRunner usage", () async {
      await testHelper.testExplicitInitializerShouldReportError();
    });

    test("[Positive] does not count assignment to TransactionRunner as usage", () async {
      await testHelper.testTransactionRunnerAssignmentShouldReportError();
    });

    test("[Positive] reports the diagnostic as an analyzer error", () {
      expect(AvoidUnusedTransactionRunnerRule().diagnosticCode.severity, DiagnosticSeverity.ERROR);
    });

    test("[Negative] does not report an error when a UseCase invokes TransactionRunner", () async {
      await testHelper.testInvokedTransactionRunnerShouldNotReportError();
    });

    test("[Negative] does not report an error when a UseCase delegates TransactionRunner", () async {
      await testHelper.testDelegatedTransactionRunnerShouldNotReportError();
    });

    test("[Negative] does not report an error when a UseCase exposes TransactionRunner to a mixin", () async {
      await testHelper.testTransactionRunnerGetterShouldNotReportError();
    });

    test("[Negative] does not report an error outside a UseCase", () async {
      await testHelper.testUnusedTransactionRunnerOutsideUseCaseShouldNotReportError();
    });

    test("[Negative] does not report an error for a static TransactionRunner", () async {
      await testHelper.testStaticTransactionRunnerShouldNotReportError();
    });

    test("[Negative] does not report an error for an unrelated type with a similar name", () async {
      await testHelper.testUnrelatedTypeShouldNotReportError();
    });

    test("[Negative] does not report an error for an unrelated TransactionRunner with the same name", () async {
      await testHelper.testUnrelatedTransactionRunnerWithSameNameShouldNotReportError();
    });

    test("[Negative] does not report an error for an unrelated UseCase with the same name", () async {
      await testHelper.testUnrelatedUseCaseWithSameNameShouldNotReportError();
    });
  });
}

class AvoidUnusedTransactionRunnerRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidUnusedTransactionRunnerRule();
    final applicationCorePackage = newPackage("flutter_architecture");
    applicationCorePackage.addFile("lib/application/use_case.dart", "abstract class UseCase {}");
    applicationCorePackage.addFile("lib/common/transaction/transaction_runner.dart", """
abstract class TransactionRunner {
  Future<T> run<T>(Future<T> Function() operation);
}

abstract class AtomicTransactionRunner extends TransactionRunner {}
""");
    super.setUp();
  }

  Future<void> testUnusedTransactionRunnerShouldReportError() async {
    final code =
        """
$_testTypes

class SampleUseCase extends UseCase {
  final AtomicTransactionRunner transactionRunner;

  SampleUseCase(this.transactionRunner);

  Future<void> execute() async {}
}
""";
    await assertDiagnostics(code, [lint(code.indexOf("transactionRunner;"), "transactionRunner".length)]);
  }

  Future<void> testUnusedTransactionRunnerInCommandShouldReportError() async {
    final code =
        """
$_testTypes

abstract class Command extends UseCase {}

class SampleCommand extends Command {
  final AtomicTransactionRunner transactionRunner;

  SampleCommand(this.transactionRunner);
}
""";
    await assertDiagnostics(code, [lint(code.indexOf("transactionRunner;"), "transactionRunner".length)]);
  }

  Future<void> testUnusedBoundedTransactionRunnerShouldReportError() async {
    final code =
        """
$_testTypes

class SampleUseCase<T extends TransactionRunner> extends UseCase {
  final T transactionRunner;

  SampleUseCase(this.transactionRunner);
}
""";
    await assertDiagnostics(code, [lint(code.indexOf("transactionRunner;"), "transactionRunner".length)]);
  }

  Future<void> testOnlyUnusedTransactionRunnerShouldReportError() async {
    final code =
        """
$_testTypes

class SampleUseCase extends UseCase {
  final AtomicTransactionRunner usedTransaction;
  final AtomicTransactionRunner unusedTransaction;

  SampleUseCase(this.usedTransaction, this.unusedTransaction);

  Future<void> execute() {
    return usedTransaction.run(() async {});
  }
}
""";
    await assertDiagnostics(code, [lint(code.indexOf("unusedTransaction;"), "unusedTransaction".length)]);
  }

  Future<void> testExplicitInitializerShouldReportError() async {
    final code =
        """
$_testTypes

class SampleUseCase extends UseCase {
  final AtomicTransactionRunner transactionRunner;

  SampleUseCase(AtomicTransactionRunner runner) : transactionRunner = runner;

  Future<void> execute() async {}
}
""";
    await assertDiagnostics(code, [lint(code.indexOf("transactionRunner;"), "transactionRunner".length)]);
  }

  Future<void> testTransactionRunnerAssignmentShouldReportError() async {
    final code =
        """
$_testTypes

class SampleUseCase extends UseCase {
  late AtomicTransactionRunner transactionRunner;

  SampleUseCase(AtomicTransactionRunner runner) {
    transactionRunner = runner;
  }
}
""";
    await assertDiagnostics(code, [lint(code.indexOf("transactionRunner;"), "transactionRunner".length)]);
  }

  Future<void> testInvokedTransactionRunnerShouldNotReportError() async {
    await assertNoDiagnostics("""
$_testTypes

class SampleUseCase extends UseCase {
  final AtomicTransactionRunner transactionRunner;

  SampleUseCase(this.transactionRunner);

  Future<void> execute() {
    return transactionRunner.run(() async {});
  }
}
""");
  }

  Future<void> testDelegatedTransactionRunnerShouldNotReportError() async {
    await assertNoDiagnostics("""
$_testTypes

Future<void> runTransaction(TransactionRunner transactionRunner) {
  return transactionRunner.run(() async {});
}

class SampleUseCase extends UseCase {
  final AtomicTransactionRunner transactionRunner;

  SampleUseCase(this.transactionRunner);

  Future<void> execute() => runTransaction(transactionRunner);
}
""");
  }

  Future<void> testTransactionRunnerGetterShouldNotReportError() async {
    await assertNoDiagnostics("""
$_testTypes

mixin TransactionBoundary on UseCase {
  TransactionRunner get transaction;
}

class SampleUseCase extends UseCase with TransactionBoundary {
  final AtomicTransactionRunner _transactionRunner;

  SampleUseCase(this._transactionRunner);

  @override
  TransactionRunner get transaction => _transactionRunner;
}
""");
  }

  Future<void> testUnusedTransactionRunnerOutsideUseCaseShouldNotReportError() async {
    await assertNoDiagnostics("""
$_transactionRunnerImport

class DatabaseSession {
  final AtomicTransactionRunner transactionRunner;

  DatabaseSession(this.transactionRunner);
}
""");
  }

  Future<void> testStaticTransactionRunnerShouldNotReportError() async {
    await assertNoDiagnostics("""
$_testTypes

class SampleUseCase extends UseCase {
  static late final AtomicTransactionRunner transactionRunner;
}
""");
  }

  Future<void> testUnrelatedTypeShouldNotReportError() async {
    await assertNoDiagnostics("""
$_useCaseImport

class TransactionRunnerConfiguration {}

class SampleUseCase extends UseCase {
  final TransactionRunnerConfiguration transactionRunner;

  SampleUseCase(this.transactionRunner);
}
""");
  }

  Future<void> testUnrelatedTransactionRunnerWithSameNameShouldNotReportError() async {
    await assertNoDiagnostics("""
$_useCaseImport

abstract class TransactionRunner {}

class SampleUseCase extends UseCase {
  final TransactionRunner transactionRunner;

  SampleUseCase(this.transactionRunner);
}
""");
  }

  Future<void> testUnrelatedUseCaseWithSameNameShouldNotReportError() async {
    await assertNoDiagnostics("""
$_transactionRunnerImport

abstract class UseCase {}

class SampleUseCase extends UseCase {
  final AtomicTransactionRunner transactionRunner;

  SampleUseCase(this.transactionRunner);
}
""");
  }
}

const _testTypes =
    """
$_useCaseImport
$_transactionRunnerImport
""";

const _useCaseImport = 'import "package:flutter_architecture/application/use_case.dart";';
const _transactionRunnerImport = 'import "package:flutter_architecture/common/transaction/transaction_runner.dart";';
