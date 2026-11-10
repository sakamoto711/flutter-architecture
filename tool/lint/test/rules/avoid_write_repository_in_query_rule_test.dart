import "package:analyzer_testing/analysis_rule/analysis_rule.dart";
import "package:flutter_architecture_lint/rules/avoid_write_repository_in_query_rule.dart";
import "package:test/test.dart";

void main() {
  for (final indirect in [false, true]) {
    for (final alias in [false, true]) {
      test("Query indirect=$indirect alias=$alias rejects a write capability", () async {
        final helper = _RuleTest()..setUp();
        await helper.check(indirect: indirect, alias: alias, write: true);
      });
    }
  }
  test("Read repositories are allowed", () async {
    await (_RuleTest()..setUp()).check(write: false);
  });
  test("An unrelated class named Query is allowed", () async {
    await (_RuleTest()..setUp()).check(unrelated: true);
  });
}

class _RuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidWriteRepositoryInQueryRule();
    final package = newPackage("flutter_architecture");
    package.addFile("lib/application/use_case.dart", "abstract class Query {}\nabstract class Intermediate extends Query {}");
    package.addFile("lib/domain/shared/repository/write/write_repository.dart", "abstract interface class WriteRepository {}");
    package.addFile("lib/repositories.dart", """
import 'domain/shared/repository/write/write_repository.dart';
abstract interface class Writer implements WriteRepository {}
abstract interface class Reader {}
typedef WriterAlias = Writer;
""");
    super.setUp();
  }

  Future<void> check({bool indirect = false, bool alias = false, bool write = true, bool unrelated = false}) async {
    final type = write ? (alias ? "WriterAlias" : "Writer") : "Reader";
    final base = indirect ? "Intermediate" : "Query";
    final queryImport = unrelated ? "" : """import "package:flutter_architecture/application/use_case.dart";""";
    final source =
        """
$queryImport
import "package:flutter_architecture/repositories.dart";
${unrelated ? "abstract class Query {}" : ""}
abstract class SampleQuery extends $base {
  $type get repository;
}
""";
    if (write && !unrelated) {
      await assertDiagnostics(source, [lint(source.indexOf("$type get"), type.length)]);
    } else {
      await assertNoDiagnostics(source);
    }
  }
}
