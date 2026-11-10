import "package:analyzer_testing/analysis_rule/analysis_rule.dart";
import "package:test/test.dart";
import "package:flutter_architecture_lint/rules/missing_field_in_props_rule.dart";
import "package:flutter_architecture_lint/rules/project_ast_visitor.dart";

void main() {
  group("MissingFieldInPropsRule", () {
    late MissingFieldInPropsRuleTest testHelper;

    setUp(() {
      ProjectAstVisitor.skipPathCheck = true;
      MissingFieldInPropsRule.skipEquatablePackageCheck = true;
      testHelper = MissingFieldInPropsRuleTest();
      testHelper.setUp();
    });

    tearDown(() {
      ProjectAstVisitor.skipPathCheck = false;
      MissingFieldInPropsRule.skipEquatablePackageCheck = false;
    });

    /// ---------- 正常系 ---------- ///

    test("[Positive] should not report error when all fields are in props", () async {
      await testHelper.testAllFieldsInPropsShouldNotReportError();
    });

    test("[Positive] should not report error for empty props with no fields", () async {
      await testHelper.testEmptyPropsWithNoFieldsShouldNotReportError();
    });

    test("[Positive] should not report error for Entity subclass", () async {
      await testHelper.testEntitySubclassShouldNotReportError();
    });

    test("[Positive] should not report error for class without Equatable", () async {
      await testHelper.testClassWithoutEquatableShouldNotReportError();
    });

    test("[Positive] should not report error for class with @IgnorePropsCheck", () async {
      await testHelper.testIgnorePropsCheckAnnotationShouldNotReportError();
    });

    test("[Positive] should not report error for subclass of @IgnorePropsCheck class", () async {
      await testHelper.testIgnorePropsCheckInheritanceShouldNotReportError();
    });

    /// ---------- 異常系 ---------- ///

    test("[Negative] should report error when field is missing in props", () async {
      await testHelper.testMissingFieldShouldReportError();
    });

    test("[Negative] should report error for multiple missing fields", () async {
      await testHelper.testMultipleMissingFieldsShouldReportError();
    });

    test("[Negative] should report error for EquatableMixin", () async {
      await testHelper.testEquatableMixinMissingFieldShouldReportError();
    });

    test("[Negative] should report error for indirect Equatable inheritance", () async {
      await testHelper.testIndirectEquatableInheritanceShouldReportError();
    });
  });
}

class MissingFieldInPropsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = MissingFieldInPropsRule();
    super.setUp();
  }

  /// 全てのフィールドがpropsに含まれている場合、エラーを報告しない
  Future<void> testAllFieldsInPropsShouldNotReportError() async {
    await assertNoDiagnostics("""
abstract class Equatable {
  const Equatable();
  List<Object?> get props;
}

class Person extends Equatable {
  final String name;
  final int age;

  const Person(this.name, this.age);

  @override
  List<Object?> get props => [name, age];
}
""");
  }

  /// フィールドがなく、propsが空の場合、エラーを報告しない
  Future<void> testEmptyPropsWithNoFieldsShouldNotReportError() async {
    await assertNoDiagnostics("""
abstract class Equatable {
  const Equatable();
  List<Object?> get props;
}

class Empty extends Equatable {
  const Empty();

  @override
  List<Object?> get props => [];
}
""");
  }

  /// Entityのサブクラスはエラーを報告しない（@IgnorePropsCheckが付与されているため）
  Future<void> testEntitySubclassShouldNotReportError() async {
    await assertNoDiagnostics("""
mixin EquatableMixin {
  List<Object?> get props;
}

class IgnorePropsCheck {
  const IgnorePropsCheck();
}

abstract class Identifier {}

@IgnorePropsCheck()
abstract class Entity<ID extends Identifier> with EquatableMixin {
  final ID identifier;
  const Entity(this.identifier);

  @override
  List<Object?> get props => [identifier];
}

class UserId extends Identifier {}

class User extends Entity<UserId> {
  final String name;
  final int age;

  const User(super.identifier, this.name, this.age);

  @override
  List<Object?> get props => [identifier];
}
""");
  }

  /// Equatableを使用していないクラスはエラーを報告しない
  Future<void> testClassWithoutEquatableShouldNotReportError() async {
    await assertNoDiagnostics("""
class Person {
  final String name;
  final int age;

  const Person(this.name, this.age);
}
""");
  }

  /// @IgnorePropsCheckアノテーションが付与されたクラスはエラーを報告しない
  Future<void> testIgnorePropsCheckAnnotationShouldNotReportError() async {
    await assertNoDiagnostics("""
abstract class Equatable {
  const Equatable();
  List<Object?> get props;
}

class IgnorePropsCheck {
  const IgnorePropsCheck();
}

@IgnorePropsCheck()
class OptionItem extends Equatable {
  final String key;
  final Object _value;

  const OptionItem(this.key, this._value);

  @override
  List<Object?> get props => [key];
}
""");
  }

  /// @IgnorePropsCheckアノテーションが付与されたクラスのサブクラスもエラーを報告しない
  Future<void> testIgnorePropsCheckInheritanceShouldNotReportError() async {
    await assertNoDiagnostics("""
abstract class Equatable {
  const Equatable();
  List<Object?> get props;
}

class IgnorePropsCheck {
  const IgnorePropsCheck();
}

@IgnorePropsCheck()
class BaseOption extends Equatable {
  final String key;

  const BaseOption(this.key);

  @override
  List<Object?> get props => [key];
}

class ChildOption extends BaseOption {
  final String label;
  final int value;

  const ChildOption(super.key, this.label, this.value);

  @override
  List<Object?> get props => [key];
}
""");
  }

  /// propsにフィールドが不足している場合、エラーを報告する
  Future<void> testMissingFieldShouldReportError() async {
    await assertDiagnostics(
      """
abstract class Equatable {
  const Equatable();
  List<Object?> get props;
}

class Person extends Equatable {
  final String name;
  final int age;

  const Person(this.name, this.age);

  @override
  List<Object?> get props => [name];
}
""",
      [lint(144, 3)],
    );
  }

  /// 複数のフィールドが不足している場合、複数のエラーを報告する
  Future<void> testMultipleMissingFieldsShouldReportError() async {
    await assertDiagnostics(
      """
abstract class Equatable {
  const Equatable();
  List<Object?> get props;
}

class Person extends Equatable {
  final String name;
  final int age;
  final String email;

  const Person(this.name, this.age, this.email);

  @override
  List<Object?> get props => [];
}
""",
      [lint(126, 4), lint(144, 3), lint(164, 5)],
    );
  }

  /// EquatableMixinを使用している場合もエラーを報告する
  Future<void> testEquatableMixinMissingFieldShouldReportError() async {
    await assertDiagnostics(
      """
mixin EquatableMixin {
  List<Object?> get props;
}

class Person with EquatableMixin {
  final String name;
  final int age;

  Person(this.name, this.age);

  @override
  List<Object?> get props => [name];
}
""",
      [lint(121, 3)],
    );
  }

  /// 間接的にEquatableを継承している場合もエラーを報告する
  Future<void> testIndirectEquatableInheritanceShouldReportError() async {
    await assertDiagnostics(
      """
abstract class Equatable {
  const Equatable();
  List<Object?> get props;
}

abstract class StateData extends Equatable {
  const StateData();
}

sealed class MenuListStateData extends StateData {
  final String categoryId;

  const MenuListStateData({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class EditableMenuListStateData extends MenuListStateData {
  final String menuId;

  const EditableMenuListStateData({
    required super.categoryId,
    required this.menuId,
  });

  @override
  List<Object?> get props => [...super.props];
}
""",
      [lint(415, 6)],
    );
  }
}
