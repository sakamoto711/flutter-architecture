import "package:analysis_server_plugin/edit/dart/correction_producer.dart";
import "package:analyzer/analysis_rule/rule_context.dart";
import "package:analyzer/analysis_rule/rule_visitor_registry.dart";
import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/dart/element/type.dart";
import "package:analyzer/error/error.dart";
import "package:analyzer_plugin/utilities/change_builder/change_builder_core.dart";
import "package:analyzer_plugin/utilities/fixes/fixes.dart";
import "package:analyzer_plugin/utilities/range_factory.dart";

import "project_ast_visitor.dart";
import "project_dart_lint_rule.dart";

/// 不要な型宣言回避ルール
///
/// 型推論で補える場合は、明示的な型宣言を省略してください。
/// 以下のケースで警告を出します:
/// 1. ローカル変数: `final String a = "test";`
/// 2. 静的フィールド: `static final String a = "test";`
/// 3. for-in変数: `for (final String item in items) { ... }`
/// 文脈による型推論が必要な初期化式とクロージャ引数は対象外です。
class AvoidUnnecessaryExplicitTypeRule extends ProjectDartLintRule {
  AvoidUnnecessaryExplicitTypeRule() : super(name: "avoid_unnecessary_explicit_type", description: "Avoid explicit type declarations that can be inferred.");

  @override
  LintCode get diagnosticCode =>
      const LintCode("avoid_unnecessary_explicit_type", "Avoid explicit type declarations that can be inferred.", correctionMessage: "Remove the explicit type and let Dart infer it.");

  @override
  void registerProjectNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addVariableDeclarationList(this, visitor);
    registry.addForEachPartsWithDeclaration(this, visitor);
  }
}

class _Visitor extends ProjectAstVisitor {
  _Visitor(super.rule);

  /// 関数型やtypedefは許容するかどうかを判定
  bool _shouldAllowType(DartType? type) {
    if (type == null) return true;
    if (type is FunctionType) return true;
    if (type is InterfaceType && type.alias != null) return true;
    return false;
  }

  // ----- ローカル変数・静的フィールド -----

  @override
  void visitVariableDeclarationList(VariableDeclarationList node) {
    if (!shouldLint(node)) return;

    final declaredType = node.type;
    // final または static final のみ対象
    if (!node.isFinal || declaredType == null || node.variables.length != 1) return;

    for (final variable in node.variables) {
      final initializer = variable.initializer;
      if (initializer == null) continue;

      final inferredType = initializer.staticType;
      final declaredElementType = declaredType.type;
      if (inferredType == null || declaredElementType == null) continue;

      final independent = switch (initializer) {
        IntegerLiteral() => declaredElementType.isDartCoreInt,
        StringLiteral() || BooleanLiteral() || DoubleLiteral() => true,
        SimpleIdentifier() || PrefixedIdentifier() || PropertyAccess() => true,
        _ => false,
      };
      if (!independent) continue;

      if (_shouldAllowType(declaredElementType)) continue;

      if (inferredType == declaredElementType) {
        rule.reportAtNode(declaredType);
      }
    }
  }

  // ----- for-inループ変数 -----

  @override
  void visitForEachPartsWithDeclaration(ForEachPartsWithDeclaration node) {
    if (!shouldLint(node)) return;

    final loopVariable = node.loopVariable;
    final declaredType = loopVariable.type;
    if (declaredType == null || loopVariable.keyword == null) return;

    // イテラブルの要素型を取得
    final iterable = node.iterable;
    // リテラルや呼出式の型は、ループ変数の宣言から推論される可能性がある。
    if (iterable is! SimpleIdentifier && iterable is! PrefixedIdentifier && iterable is! PropertyAccess) return;
    final iterableType = iterable.staticType;
    if (iterableType is! InterfaceType) return;

    // Iterable<E> または List<E> などから要素型を取得
    final elementType = _getIterableElementType(iterableType);
    if (elementType == null) return;

    final declaredElementType = declaredType.type;
    if (declaredElementType == null) return;

    if (_shouldAllowType(declaredElementType)) return;

    if (declaredElementType == elementType) {
      rule.reportAtNode(declaredType);
    }
  }

  /// Iterable型から要素型を取得
  DartType? _getIterableElementType(InterfaceType type) {
    // 直接 Iterable の場合
    if (type.element.name == "Iterable") {
      return type.typeArguments.firstOrNull;
    }

    // Iterable を実装している場合 (List, Set など)
    for (final interface in type.allSupertypes) {
      if (interface.element.name == "Iterable") {
        return interface.typeArguments.firstOrNull;
      }
    }

    return null;
  }

  // 関数式自身のstaticTypeから、引数型を省略できるかは判定できない。
  // このルールではクロージャの引数型を削除候補にしない。
}

/// ----- Fix -----

class AvoidUnnecessaryExplicitTypeFix extends ResolvedCorrectionProducer {
  AvoidUnnecessaryExplicitTypeFix({required super.context});

  static const _fixKind = FixKind("dart.fix.removeUnnecessaryExplicitType", 50, "Remove explicit type");

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final node = this.node;
    if (node is! TypeAnnotation) return;

    final parent = node.parent;

    // ローカル変数・静的フィールドの場合
    if (parent is VariableDeclarationList) {
      final keyword = parent.keyword;
      if (keyword == null) return;

      await builder.addDartFileEdit(file, (builder) {
        builder.addDeletion(range.startStart(node, parent.variables.first));
      });
      return;
    }

    // for-inループ変数の場合
    if (parent is DeclaredIdentifier) {
      final varName = parent.name;

      await builder.addDartFileEdit(file, (builder) {
        builder.addDeletion(range.startStart(node, varName));
      });
      return;
    }
  }
}
