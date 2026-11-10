import "package:analyzer/analysis_rule/rule_context.dart";
import "package:analyzer/analysis_rule/rule_visitor_registry.dart";
import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/dart/element/element.dart";
import "package:analyzer/error/error.dart";

import "project_ast_visitor.dart";
import "project_dart_lint_rule.dart";

/// SerializeOnly外部呼び出し回避ルール
///
/// @SerializeOnly が付与されたコンストラクタ・factoryメソッドを
/// DataSource または 同一ファイル以外で呼び出すことを回避するためのルールです。
class AvoidSerializeOnlyOutsideDataSourceRule extends ProjectDartLintRule {
  AvoidSerializeOnlyOutsideDataSourceRule()
    : super(name: "avoid_serialize_only_outside_data_source", description: "@SerializeOnly constructors must only be called from DataSource classes or the same file.");

  @override
  LintCode get diagnosticCode => const LintCode(
    "avoid_serialize_only_outside_data_source",
    "@SerializeOnly constructors must only be called from DataSource classes or the same file.",
    correctionMessage: "Call this constructor only from DataSource classes or the same file.",
  );

  @override
  void registerProjectNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addInstanceCreationExpression(this, _Visitor(this));
  }
}

class _Visitor extends ProjectAstVisitor {
  _Visitor(super.rule);

  bool _isDataSourcePath(String path) {
    return path.contains("/infrastructure/data_source/");
  }

  bool _isSameFile(String callerPath, ConstructorElement targetElement) {
    final targetPath = targetElement.library.firstFragment.source.fullName;
    final normalizedCallerPath = callerPath.replaceAll(".g.dart", ".dart");
    final normalizedTargetPath = targetPath.replaceAll(".g.dart", ".dart");
    return normalizedCallerPath == normalizedTargetPath;
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!shouldLint(node)) return;

    final callerPath = getFilePath(node);
    if (callerPath == null) return;

    if (_isDataSourcePath(callerPath)) return;

    final constructorElement = node.constructorName.element;
    if (constructorElement != null && _hasSerializeOnlyAnnotation(constructorElement) && !_isSameFile(callerPath, constructorElement)) {
      rule.reportAtNode(node);
    }
  }

  bool _hasSerializeOnlyAnnotation(ConstructorElement element) {
    for (final annotation in element.metadata.annotations) {
      final annotationType = annotation.computeConstantValue()?.type;
      if (annotationType != null) {
        final typeName = annotationType.getDisplayString();
        if (typeName == "SerializeOnly") return true;
      }
    }
    return false;
  }
}
