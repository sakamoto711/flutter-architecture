import "package:analyzer/analysis_rule/rule_context.dart";
import "package:analyzer/analysis_rule/rule_visitor_registry.dart";
import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/dart/ast/visitor.dart";
import "package:analyzer/dart/element/element.dart";
import "package:analyzer/dart/element/type.dart";
import "package:analyzer/error/error.dart";

import "project_ast_visitor.dart";
import "project_dart_lint_rule.dart";

const _useCaseLibraryUri = "package:flutter_architecture/application/use_case.dart";
const _transactionRunnerLibraryUri = "package:flutter_architecture/common/transaction/transaction_runner.dart";

/// TransactionRunner未使用回避ルール
///
/// UseCaseへ注入したTransactionRunnerが利用されていない場合にエラーとします。
class AvoidUnusedTransactionRunnerRule extends ProjectDartLintRule {
  AvoidUnusedTransactionRunnerRule() : super(name: "avoid_unused_transaction_runner", description: "UseCase must use every injected TransactionRunner.");

  @override
  LintCode get diagnosticCode => const LintCode(
    "avoid_unused_transaction_runner",
    "UseCase must use every injected TransactionRunner.",
    correctionMessage: "Use the TransactionRunner in the UseCase or remove it from the dependencies.",
    severity: DiagnosticSeverity.ERROR,
  );

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends ProjectAstVisitor {
  _Visitor(super.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!shouldLint(node)) return;

    final classElement = node.declaredFragment?.element;
    if (classElement == null || !_isUseCase(classElement.thisType)) return;

    final transactionRunnerFields = <FieldElement, VariableDeclaration>{};
    for (final fieldDeclaration in _classMembers(node).whereType<FieldDeclaration>()) {
      for (final variable in fieldDeclaration.fields.variables) {
        final element = variable.declaredFragment?.element;
        if (element is! FieldElement || element.isStatic || !_isTransactionRunner(element.type)) {
          continue;
        }
        transactionRunnerFields[element.baseElement] = variable;
      }
    }
    if (transactionRunnerFields.isEmpty) return;

    final usageVisitor = _FieldUsageVisitor(transactionRunnerFields.keys.toSet());
    node.visitChildren(usageVisitor);

    for (final entry in transactionRunnerFields.entries) {
      if (!usageVisitor.usedFields.contains(entry.key)) {
        rule.reportAtNode(entry.value);
      }
    }
  }
}

class _FieldUsageVisitor extends RecursiveAstVisitor<void> {
  final Set<FieldElement> targetFields;
  final Set<FieldElement> usedFields = {};

  _FieldUsageVisitor(this.targetFields);

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.parent case final ConstructorFieldInitializer initializer when identical(initializer.fieldName, node)) {
      return;
    }

    if (!node.inGetterContext()) {
      super.visitSimpleIdentifier(node);
      return;
    }

    final field = _fieldOf(node.element);
    if (field != null && targetFields.contains(field)) {
      usedFields.add(field);
    }
    super.visitSimpleIdentifier(node);
  }
}

FieldElement? _fieldOf(Element? element) {
  final field = switch (element) {
    final FieldElement field => field,
    final PropertyAccessorElement accessor when accessor.variable is FieldElement => accessor.variable,
    _ => null,
  };
  final baseElement = field?.baseElement;
  return baseElement is FieldElement ? baseElement : null;
}

Iterable<ClassMember> _classMembers(ClassDeclaration node) {
  final body = node.body;
  return body is BlockClassBody ? body.members : const <ClassMember>[];
}

bool _isUseCase(InterfaceType type) => _isTypeOrSubtypeOf(type, name: "UseCase", libraryUri: _useCaseLibraryUri);

bool _isTransactionRunner(DartType type) => switch (type) {
  final InterfaceType interfaceType => _isTypeOrSubtypeOf(interfaceType, name: "TransactionRunner", libraryUri: _transactionRunnerLibraryUri),
  final TypeParameterType typeParameterType => _isTransactionRunner(typeParameterType.bound),
  _ => false,
};

bool _isTypeOrSubtypeOf(InterfaceType type, {required String name, required String libraryUri}) {
  bool isTarget(InterfaceType candidate) => candidate.element.name == name && candidate.element.enclosingElement.uri.toString() == libraryUri;

  return isTarget(type) || type.allSupertypes.any(isTarget);
}
