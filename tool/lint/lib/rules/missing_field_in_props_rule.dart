import "package:analysis_server_plugin/edit/dart/correction_producer.dart";
import "package:analyzer/analysis_rule/rule_context.dart";
import "package:analyzer/analysis_rule/rule_visitor_registry.dart";
import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/dart/element/element.dart";
import "package:analyzer/dart/element/type.dart";
import "package:analyzer/error/error.dart";
import "package:analyzer_plugin/utilities/change_builder/change_builder_core.dart";
import "package:analyzer_plugin/utilities/fixes/fixes.dart";
import "package:meta/meta.dart";

import "project_ast_visitor.dart";
import "project_dart_lint_rule.dart";

/// Equatableのpropsにフィールドが不足していることを検出するルール
///
/// Equatable または EquatableMixin を使用しているクラスで、
/// propsゲッターに含まれていないフィールドがある場合に警告を出します。
///
/// `@IgnorePropsCheck`アノテーションが付与されたクラス（継承先含む）は除外されます。
class MissingFieldInPropsRule extends ProjectDartLintRule {
  /// テスト時にEquatableパッケージのチェックをスキップするためのフラグ
  @visibleForTesting
  static bool skipEquatablePackageCheck = false;

  MissingFieldInPropsRule() : super(name: "missing_field_in_props", description: "All instance fields should be included in Equatable's props.");

  @override
  LintCode get diagnosticCode =>
      const LintCode("missing_field_in_props", "Field '{0}' is not included in props.", correctionMessage: "Add the field to the props list for correct equality comparison.");

  @override
  void registerProjectNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends ProjectAstVisitor {
  _Visitor(super.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!shouldLint(node)) return;

    final classElement = node.declaredFragment?.element;
    if (classElement == null) return;

    // Equatable または EquatableMixin を使用しているか確認
    if (!_usesEquatable(classElement)) return;

    // @IgnorePropsCheckアノテーションが付与されている場合は除外（継承先含む）
    if (_hasIgnorePropsCheckAnnotation(classElement)) return;

    // クラスのインスタンスフィールドを取得
    final instanceFields = _getInstanceFields(node);
    if (instanceFields.isEmpty) return;

    // propsゲッターを取得
    final propsGetter = _findPropsGetter(node);
    // An abstract equality contract may be implemented by concrete subclasses.
    if (propsGetter == null) {
      final inherited = classElement.lookUpGetter(name: "props", library: classElement.library);
      if (inherited == null || inherited.isAbstract) return;
    }
    // Concrete inherited props cannot include fields introduced by this class.
    final propsFieldNames = propsGetter == null ? <String>{} : _getPropsFieldNames(propsGetter);

    // 不足しているフィールドを検出
    for (final field in instanceFields) {
      if (!propsFieldNames.contains(field.name)) {
        rule.reportAtNode(field.declaration, arguments: [field.name]);
      }
    }
  }

  /// Equatable または EquatableMixin を使用しているか確認（継承チェーンをたどる）
  bool _usesEquatable(InterfaceElement element) {
    // 自身をチェック
    if (_hasEquatableInElement(element)) return true;

    // 継承チェーンをたどってEquatableを探す
    InterfaceType? current = element.supertype;
    while (current != null) {
      if (_isEquatableType(current) || _isEquatableMixinType(current)) {
        return true;
      }
      if (_hasEquatableInElement(current.element)) {
        return true;
      }
      current = current.element.supertype;
    }

    return false;
  }

  /// 要素がEquatableをmixinまたはimplementsしているかチェック
  bool _hasEquatableInElement(InterfaceElement element) {
    // mixins (with Equatable, with EquatableMixin)
    for (final mixin in element.mixins) {
      if (_isEquatableType(mixin) || _isEquatableMixinType(mixin)) {
        return true;
      }
    }
    // interfaces (implements Equatable, implements EquatableMixin)
    for (final interface in element.interfaces) {
      if (_isEquatableType(interface) || _isEquatableMixinType(interface)) {
        return true;
      }
    }
    return false;
  }

  bool _isEquatableType(InterfaceType type) {
    return type.element.name == "Equatable" && _isEquatablePackage(type.element);
  }

  bool _isEquatableMixinType(InterfaceType type) {
    return type.element.name == "EquatableMixin" && _isEquatablePackage(type.element);
  }

  bool _isEquatablePackage(InterfaceElement element) {
    if (MissingFieldInPropsRule.skipEquatablePackageCheck) return true;

    final source = element.library.firstFragment.source;
    return source.fullName.contains("equatable");
  }

  /// @IgnorePropsCheckアノテーションが付与されているか確認（継承先含む）
  bool _hasIgnorePropsCheckAnnotation(InterfaceElement element) {
    // 自身のアノテーションを確認
    if (_hasAnnotation(element, "IgnorePropsCheck")) {
      return true;
    }

    // 継承元をたどってアノテーションを確認
    InterfaceType? current = element.supertype;
    while (current != null) {
      if (_hasAnnotation(current.element, "IgnorePropsCheck")) {
        return true;
      }
      current = current.element.supertype;
    }

    return false;
  }

  /// 指定した名前のアノテーションを持つか確認
  bool _hasAnnotation(InterfaceElement element, String annotationName) {
    for (final annotation in element.metadata.annotations) {
      final annotationType = annotation.computeConstantValue()?.type;
      if (annotationType != null) {
        final typeName = annotationType.getDisplayString();
        if (typeName == annotationName) return true;
      }
    }
    return false;
  }

  /// クラスのインスタンスフィールドを取得
  List<_FieldInfo> _getInstanceFields(ClassDeclaration node) {
    final fields = <_FieldInfo>[];

    for (final member in _classMembers(node)) {
      if (member is FieldDeclaration && !member.isStatic) {
        for (final variable in member.fields.variables) {
          fields.add(_FieldInfo(name: variable.name.lexeme, declaration: variable));
        }
      }
    }

    return fields;
  }

  /// propsゲッターを取得
  MethodDeclaration? _findPropsGetter(ClassDeclaration node) {
    for (final member in _classMembers(node)) {
      if (member is MethodDeclaration && member.name.lexeme == "props" && member.isGetter) {
        return member;
      }
    }
    return null;
  }

  /// propsに含まれているフィールド名を取得
  Set<String> _getPropsFieldNames(MethodDeclaration propsGetter) {
    final names = <String>{};

    final body = propsGetter.body;
    if (body is ExpressionFunctionBody) {
      _extractFieldNames(body.expression, names);
    } else if (body is BlockFunctionBody) {
      for (final statement in body.block.statements) {
        if (statement is ReturnStatement) {
          final expression = statement.expression;
          if (expression != null) _extractFieldNames(expression, names);
        }
      }
    }

    return names;
  }

  /// 式からフィールド名を抽出
  void _extractFieldNames(Expression expression, Set<String> names) {
    if (expression is ListLiteral) {
      for (final element in expression.elements) {
        if (element is SimpleIdentifier) {
          names.add(element.name);
        } else if (element is SpreadElement && element.expression is SimpleIdentifier) {
          names.add((element.expression as SimpleIdentifier).name);
        }
      }
    }
  }
}

class _FieldInfo {
  final String name;
  final VariableDeclaration declaration;

  _FieldInfo({required this.name, required this.declaration});
}

Iterable<ClassMember> _classMembers(ClassDeclaration node) {
  final body = node.body;
  return body is BlockClassBody ? body.members : const <ClassMember>[];
}

/// ----- Fix -----

class MissingFieldInPropsFix extends ResolvedCorrectionProducer {
  MissingFieldInPropsFix({required super.context});

  static const _fixKind = FixKind("dart.fix.addFieldToProps", 50, "Add field to props");

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    // エラーが報告されたノード（VariableDeclaration）を取得
    final node = this.node;
    if (node is! VariableDeclaration) return;

    final fieldName = node.name.lexeme;

    // クラス宣言を取得
    final classDeclaration = node.thisOrAncestorOfType<ClassDeclaration>();
    if (classDeclaration == null) return;

    // propsゲッターを取得
    final propsGetter = _findPropsGetter(classDeclaration);
    if (propsGetter == null) return;

    // propsのリストリテラルを取得
    final listLiteral = _findPropsListLiteral(propsGetter);
    if (listLiteral == null) return;

    await builder.addDartFileEdit(file, (builder) {
      final elements = listLiteral.elements;
      if (elements.isEmpty) {
        // 空のリストの場合: [] → [fieldName]
        builder.addSimpleInsertion(listLiteral.leftBracket.end, fieldName);
      } else {
        // 既存の要素がある場合: [a, b] → [a, b, fieldName]
        final lastElement = elements.last;
        builder.addSimpleInsertion(lastElement.end, ", $fieldName");
      }
    });
  }

  MethodDeclaration? _findPropsGetter(ClassDeclaration node) {
    for (final member in _classMembers(node)) {
      if (member is MethodDeclaration && member.name.lexeme == "props" && member.isGetter) {
        return member;
      }
    }
    return null;
  }

  ListLiteral? _findPropsListLiteral(MethodDeclaration propsGetter) {
    final body = propsGetter.body;
    if (body is ExpressionFunctionBody) {
      final expression = body.expression;
      if (expression is ListLiteral) {
        return expression;
      }
    } else if (body is BlockFunctionBody) {
      for (final statement in body.block.statements) {
        if (statement is ReturnStatement && statement.expression is ListLiteral) {
          return statement.expression as ListLiteral;
        }
      }
    }
    return null;
  }
}
