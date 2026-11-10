import "package:analyzer/analysis_rule/rule_context.dart";
import "package:analyzer/analysis_rule/rule_visitor_registry.dart";
import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/dart/ast/token.dart";
import "package:analyzer/error/error.dart";

import "project_ast_visitor.dart";
import "project_dart_lint_rule.dart";

/// Null強制アンラップ回避ルール
///
/// `!`演算子を用いた強制アンラップを回避するためのルールです。
/// スマートキャスト、オプショナル演算子、拡張関数`let`などを利用して安全にNotNullへ変換してください。
class AvoidNullForceUnwrapRule extends ProjectDartLintRule {
  AvoidNullForceUnwrapRule() : super(name: "avoid_null_force_unwrap", description: "Avoid using the '!' operator to force-unwrap nullable values.");

  @override
  LintCode get diagnosticCode => const LintCode(
    "avoid_null_force_unwrap",
    "Avoid using the '!' operator to force-unwrap nullable values.",
    correctionMessage: "Use smart cast, optional operator, or 'let' extension function instead.",
  );

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addPostfixExpression(this, _Visitor(this));
  }
}

class _Visitor extends ProjectAstVisitor {
  _Visitor(super.rule);

  @override
  void visitPostfixExpression(PostfixExpression node) {
    if (!shouldLint(node)) return;

    if (node.operator.type == TokenType.BANG) {
      rule.reportAtNode(node);
    }
  }
}
