import "package:analyzer/analysis_rule/rule_context.dart";
import "package:analyzer/analysis_rule/rule_visitor_registry.dart";
import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/dart/ast/visitor.dart";
import "package:analyzer/error/error.dart";

import "project_ast_visitor.dart";
import "project_dart_lint_rule.dart";

/// Query副作用回避ルール
///
/// Query-UseCase での WriteRepository 利用を回避するためのルールです。
/// WriteRepository を利用している場合にはエラーとします。
class AvoidWriteRepositoryInQueryRule extends ProjectDartLintRule {
  AvoidWriteRepositoryInQueryRule() : super(name: "avoid_write_repository_in_query", description: "Query-UseCase must not depend on Write repositories.");

  @override
  LintCode get diagnosticCode =>
      const LintCode("avoid_write_repository_in_query", "Query-UseCase must not depend on Write repositories.", correctionMessage: "Use only read repositories in Query use cases.");

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addCompilationUnit(this, _Visitor(this));
  }

  bool _isWriteRepositoryPath(String uri) {
    return RegExp(r"WriteRepository\.dart").hasMatch(uri);
  }
}

class _Visitor extends ProjectAstVisitor {
  _Visitor(AvoidWriteRepositoryInQueryRule super.rule);

  @override
  AvoidWriteRepositoryInQueryRule get rule => super.rule as AvoidWriteRepositoryInQueryRule;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    if (!shouldLint(node)) return;

    final hasQueryClass = node.declarations.whereType<ClassDeclaration>().any((c) {
      final element = c.declaredFragment?.element;
      final superType = element?.supertype;
      return superType?.element.name == "Query";
    });

    if (!hasQueryClass) return;

    for (final directive in node.directives.whereType<ImportDirective>()) {
      final uri = directive.uri.stringValue ?? "";
      if (rule._isWriteRepositoryPath(uri)) {
        rule.reportAtNode(directive.uri);
      }
    }

    node.visitChildren(_RepoIdentifierVisitor(rule));
  }
}

class _RepoIdentifierVisitor extends RecursiveAstVisitor<void> {
  _RepoIdentifierVisitor(this.rule);

  final ProjectDartLintRule rule;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.token.lexeme.endsWith("WriteRepository")) {
      rule.reportAtNode(node);
    }
    super.visitSimpleIdentifier(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (node.identifier.token.lexeme.endsWith("WriteRepository")) {
      rule.reportAtNode(node.identifier);
    }
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitNamedType(NamedType node) {
    if (node.name.lexeme.endsWith("WriteRepository")) {
      rule.reportAtNode(node);
    }
    super.visitNamedType(node);
  }
}
