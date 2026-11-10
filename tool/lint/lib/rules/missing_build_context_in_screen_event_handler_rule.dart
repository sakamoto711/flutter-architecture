import "package:analysis_server_plugin/edit/dart/correction_producer.dart";
import "package:analyzer/analysis_rule/rule_context.dart";
import "package:analyzer/analysis_rule/rule_visitor_registry.dart";
import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/error/error.dart";
import "package:analyzer_plugin/utilities/change_builder/change_builder_core.dart";
import "package:analyzer_plugin/utilities/fixes/fixes.dart";
import "package:meta/meta.dart";

import "project_ast_visitor.dart";
import "project_dart_lint_rule.dart";

/// 画面イベントハンドラのBuildContext引数不足を検出するルール
///
/// `lib/presentation/view/screen/` 配下の `onXxx` / `_onXxx` メソッドで
/// `BuildContext` 引数を持たない場合に警告します。
class MissingBuildContextInScreenEventHandlerRule extends ProjectDartLintRule {
  /// テスト時にscreenパス判定をスキップするためのフラグ
  @visibleForTesting
  static bool skipScreenPathCheck = false;

  MissingBuildContextInScreenEventHandlerRule() : super(name: "missing_build_context_in_screen_event_handler", description: "Screen event handler methods should include a BuildContext parameter.");

  @override
  LintCode get diagnosticCode => const LintCode(
    "missing_build_context_in_screen_event_handler",
    "Screen event handler methods should include a BuildContext parameter.",
    correctionMessage: "Add BuildContext as the first parameter.",
  );

  @override
  void registerProjectNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addMethodDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends ProjectAstVisitor {
  _Visitor(super.rule);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (!shouldLint(node)) return;
    if (!_isScreenPath(node)) return;

    final methodName = node.name.lexeme;
    if (!_isEventHandlerName(methodName)) return;

    final parameters = node.parameters;
    if (parameters == null) return;

    if (_hasBuildContextParameter(parameters)) return;
    rule.reportAtNode(node);
  }

  bool _isScreenPath(AstNode node) {
    if (MissingBuildContextInScreenEventHandlerRule.skipScreenPathCheck) return true;

    final path = getFilePath(node);
    if (path == null) return false;
    return path.contains("/presentation/view/screen/");
  }
}

bool _isEventHandlerName(String name) => RegExp(r"^_?on[A-Z]").hasMatch(name);

bool _hasBuildContextParameter(FormalParameterList parameterList) {
  return parameterList.parameters.any(_isBuildContextParameter);
}

bool _isBuildContextParameter(FormalParameter parameter) {
  final type = parameter.type;
  if (type == null) return false;

  final typeSource = type.toSource();
  return typeSource == "BuildContext" || typeSource == "BuildContext?" || typeSource.endsWith(".BuildContext") || typeSource.endsWith(".BuildContext?");
}

/// ----- Fix -----

class MissingBuildContextInScreenEventHandlerFix extends ResolvedCorrectionProducer {
  MissingBuildContextInScreenEventHandlerFix({required super.context});

  static const _fixKind = FixKind("dart.fix.addBuildContextToScreenEventHandler", 50, "Add BuildContext parameter");

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final currentNode = node;
    final methodDeclaration = currentNode.thisOrAncestorOfType<MethodDeclaration>();
    if (methodDeclaration == null) return;

    if (!_isEventHandlerName(methodDeclaration.name.lexeme)) return;
    if (!_isScreenPath(file)) return;

    final parameters = methodDeclaration.parameters;
    if (parameters == null) return;
    if (_hasBuildContextParameter(parameters)) return;

    final insertion = parameters.parameters.isEmpty ? "BuildContext context" : "BuildContext context, ";
    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleInsertion(parameters.leftParenthesis.end, insertion);
    });
  }

  bool _isScreenPath(String path) => path.contains("/presentation/view/screen/");
}
