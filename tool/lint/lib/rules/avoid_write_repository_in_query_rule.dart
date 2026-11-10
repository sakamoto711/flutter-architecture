import "package:analyzer/analysis_rule/rule_context.dart";
import "package:analyzer/analysis_rule/rule_visitor_registry.dart";
import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/dart/ast/visitor.dart";
import "package:analyzer/dart/element/element.dart";
import "package:analyzer/dart/element/type.dart";
import "package:analyzer/error/error.dart";
import "project_ast_visitor.dart";
import "project_dart_lint_rule.dart";

/// Queryの継承関係と書き込み契約の定義元に基づいて依存違反を検査する。
class AvoidWriteRepositoryInQueryRule extends ProjectDartLintRule {
  AvoidWriteRepositoryInQueryRule() : super(name: "avoid_write_repository_in_query", description: "Query must not depend on write repositories.");
  @override
  LintCode get diagnosticCode => const LintCode("avoid_write_repository_in_query", "Query must not depend on write repositories.");
  @override
  void registerProjectNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

bool _isContract(InterfaceElement element, String name, String path) => element.name == name && element.library.uri.toString() == "package:flutter_architecture/$path";

class _Visitor extends ProjectAstVisitor {
  _Visitor(super.rule);
  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!shouldLint(node)) return;
    final element = node.declaredFragment?.element;
    if (element == null || !element.allSupertypes.any((type) => _isContract(type.element, "Query", "application/use_case.dart"))) return;
    node.visitChildren(_WriteTypeVisitor(rule));
  }
}

class _WriteTypeVisitor extends RecursiveAstVisitor<void> {
  final ProjectDartLintRule rule;
  _WriteTypeVisitor(this.rule);
  @override
  void visitNamedType(NamedType node) {
    final type = node.type;
    if (type is InterfaceType && [type, ...type.element.allSupertypes].any((type) => _isContract(type.element, "WriteRepository", "domain/shared/repository/write/write_repository.dart"))) {
      rule.reportAtNode(node);
    }
    super.visitNamedType(node);
  }
}
