import "package:analysis_server_plugin/edit/dart/correction_producer.dart";
import "package:analyzer/analysis_rule/rule_context.dart";
import "package:analyzer/analysis_rule/rule_visitor_registry.dart";
import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/dart/ast/visitor.dart";
import "package:analyzer/error/error.dart";
import "package:analyzer_plugin/utilities/change_builder/change_builder_core.dart";
import "package:analyzer_plugin/utilities/fixes/fixes.dart";
import "package:analyzer_plugin/utilities/range_factory.dart";

import "project_ast_visitor.dart";
import "project_dart_lint_rule.dart";

/// Future並列処理メソッド内でawaitを使用することを禁止するルール
///
/// `Future.tuple`、`Future.triple`などの並列処理メソッドは並列実行を意図しているため、
/// 引数内でawaitすると逐次実行になり、意図した動作になりません。
///
/// ```dart
/// // NG: 逐次実行になる
/// final result = await Future.tuple(await op1(), await op2());
///
/// // OK: 並列実行
/// final result = await Future.tuple(op1(), op2());
/// ```
class AvoidAwaitInFutureParallelRule extends ProjectDartLintRule {
  AvoidAwaitInFutureParallelRule() : super(name: "avoid_await_in_future_parallel", description: "Avoid using 'await' inside Future parallel method arguments.");

  @override
  LintCode get diagnosticCode => const LintCode(
    "avoid_await_in_future_parallel",
    "Avoid using 'await' inside Future parallel method arguments. This causes sequential execution instead of parallel.",
    correctionMessage: "Remove 'await' from inside Future.tuple/triple/etc. arguments.",
  );

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addMethodInvocation(this, _Visitor(this));
  }
}

class _Visitor extends ProjectAstVisitor {
  _Visitor(super.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (!shouldLint(node)) return;

    if (_isFutureParallelCall(node)) {
      node.argumentList.accept(_AwaitFinder(rule));
    }
  }

  bool _isFutureParallelCall(MethodInvocation node) {
    final element = node.methodName.element;
    if (element == null) return false;

    final source = element.library?.firstFragment.source;
    if (source == null) return false;

    if (!source.fullName.endsWith("future_extension.dart")) return false;

    final target = node.target;
    return target is SimpleIdentifier && target.name == "Future";
  }
}

class _AwaitFinder extends RecursiveAstVisitor<void> {
  _AwaitFinder(this.rule);

  final ProjectDartLintRule rule;

  @override
  void visitAwaitExpression(AwaitExpression node) {
    rule.reportAtNode(node);
    super.visitAwaitExpression(node);
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    // ラムダ内部の await は許容する（ラムダ自体は即座に Future を返すため）
    // visitChildren しない
  }
}

/// ----- Fix -----

class AvoidAwaitInFutureParallelFix extends ResolvedCorrectionProducer {
  AvoidAwaitInFutureParallelFix({required super.context});

  static const _fixKind = FixKind("dart.fix.removeAwaitInFutureParallel", 50, "Remove 'await'");

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final node = this.node;
    if (node is! AwaitExpression) return;

    final awaitKeyword = node.awaitKeyword;
    final expression = node.expression;

    await builder.addDartFileEdit(file, (builder) {
      // await キーワードと後続のスペースを削除
      builder.addDeletion(range.startStart(awaitKeyword, expression));
    });
  }
}
