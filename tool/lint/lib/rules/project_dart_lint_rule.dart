import "package:analyzer/analysis_rule/analysis_rule.dart";

/// プロジェクト固有のカスタムLintルール基底クラス
abstract class ProjectDartLintRule extends AnalysisRule {
  ProjectDartLintRule({required super.name, required super.description});
}
