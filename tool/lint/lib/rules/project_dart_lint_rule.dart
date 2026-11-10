import "package:analyzer/analysis_rule/analysis_rule.dart";
import "package:analyzer/analysis_rule/rule_context.dart";
import "package:analyzer/analysis_rule/rule_visitor_registry.dart";

/// プロジェクト固有のカスタムLintルール基底クラス
abstract class ProjectDartLintRule extends AnalysisRule {
  ProjectDartLintRule({required super.name, required super.description});
  String? packageRoot;
  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    packageRoot = context.package?.root.path;
    registerProjectNodeProcessors(registry, context);
  }

  void registerProjectNodeProcessors(RuleVisitorRegistry registry, RuleContext context);
}
