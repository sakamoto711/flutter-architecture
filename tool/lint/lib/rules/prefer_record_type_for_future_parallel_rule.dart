import "package:analyzer/analysis_rule/rule_context.dart";
import "package:analyzer/analysis_rule/rule_visitor_registry.dart";
import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/error/error.dart";

import "project_ast_visitor.dart";
import "project_dart_lint_rule.dart";

/// Future並列処理メソッドの結果をRecord型に変換することを推奨するルール
///
/// `Future.tuple`、`Future.triple`などの並列処理メソッドは、
/// `.toRecordType()`を使用してRecord型に変換することを推奨します。
///
/// ```dart
/// // NG: Tuple/Triple等のクラス型で受け取る
/// final tuple = await Future.tuple(op1(), op2());
/// print(tuple.first);
///
/// // OK: Record型に変換して分割代入
/// final (first, second) = await Future.tuple(op1(), op2()).toRecordType();
/// print(first);
/// ```
class PreferRecordTypeForFutureParallelRule extends ProjectDartLintRule {
  PreferRecordTypeForFutureParallelRule() : super(name: "prefer_record_type_for_future_parallel", description: "Use '.toRecordType()' to convert Future parallel result to Record type.");

  @override
  LintCode get diagnosticCode => const LintCode(
    "prefer_record_type_for_future_parallel",
    "Use '.toRecordType()' to convert Future parallel result to Record type.",
    correctionMessage: "Add '.toRecordType()' to the Future.tuple/triple call.",
  );

  @override
  void registerProjectNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addMethodInvocation(this, _Visitor(this));
  }
}

class _Visitor extends ProjectAstVisitor {
  _Visitor(super.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (!shouldLint(node)) return;

    if (_isFutureParallelCall(node) && !_hasToRecordTypeCall(node)) {
      rule.reportAtNode(node);
    }
  }

  bool _isFutureParallelCall(MethodInvocation node) {
    final element = node.methodName.element;
    if (element == null) return false;

    final source = element.library?.firstFragment.source;
    if (source == null) return false;

    if (!source.fullName.endsWith("future_extension.dart")) return false;
    if (node.methodName.name == "waitAll") return false;

    final target = node.target;
    return target is SimpleIdentifier && target.name == "Future";
  }

  bool _hasToRecordTypeCall(MethodInvocation node) {
    final parent = node.parent;
    return parent is MethodInvocation && parent.methodName.name == "toRecordType";
  }
}
