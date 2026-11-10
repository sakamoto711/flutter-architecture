import "package:analyzer/analysis_rule/rule_context.dart";
import "package:analyzer/analysis_rule/rule_visitor_registry.dart";
import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/dart/element/element.dart";
import "package:analyzer/error/error.dart";

import "project_ast_visitor.dart";
import "project_dart_lint_rule.dart";

/// DeserializeOnly外部アクセス回避ルール
///
/// @DeserializeOnly が付与されたフィールド・メソッドを
/// DataSource以外でアクセスすることを回避するためのルールです。
class AvoidDeserializeOnlyOutsideDataSourceRule extends ProjectDartLintRule {
  AvoidDeserializeOnlyOutsideDataSourceRule() : super(name: "avoid_deserialize_only_outside_data_source", description: "@DeserializeOnly members must only be accessed from DataSource classes.");

  @override
  LintCode get diagnosticCode => const LintCode(
    "avoid_deserialize_only_outside_data_source",
    "@DeserializeOnly members must only be accessed from DataSource classes.",
    correctionMessage: "Access this member only from within DataSource classes.",
  );

  @override
  void registerProjectNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addPropertyAccess(this, visitor);
    registry.addPrefixedIdentifier(this, visitor);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends ProjectAstVisitor {
  _Visitor(super.rule);

  bool _isDataSourcePath(String path) {
    return path.contains("/infrastructure/data_source/");
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (!shouldLint(node)) return;

    final path = getFilePath(node);
    if (path != null && _isDataSourcePath(path)) return;

    _checkDeserializeOnlyAccess(node.propertyName);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (!shouldLint(node)) return;

    final path = getFilePath(node);
    if (path != null && _isDataSourcePath(path)) return;

    _checkDeserializeOnlyAccess(node.methodName);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (!shouldLint(node)) return;

    final path = getFilePath(node);
    if (path != null && _isDataSourcePath(path)) return;

    _checkDeserializeOnlyAccess(node.identifier);
  }

  void _checkDeserializeOnlyAccess(SimpleIdentifier identifier) {
    final element = identifier.element;
    if (element == null) return;

    if (element is GetterElement) {
      final variable = element.variable;
      if (variable is FieldElement && _hasDeserializeOnlyAnnotation(variable)) {
        rule.reportAtNode(identifier);
      }
    }

    if (element is FieldElement && _hasDeserializeOnlyAnnotation(element)) {
      rule.reportAtNode(identifier);
    }

    if (element is MethodElement && _hasDeserializeOnlyAnnotation(element)) {
      rule.reportAtNode(identifier);
    }
  }

  bool _hasDeserializeOnlyAnnotation(Element element) {
    for (final annotation in element.metadata.annotations) {
      final annotationType = annotation.computeConstantValue()?.type;
      if (annotationType != null) {
        final typeName = annotationType.getDisplayString();
        if (typeName == "DeserializeOnly") return true;
      }
    }
    return false;
  }
}
