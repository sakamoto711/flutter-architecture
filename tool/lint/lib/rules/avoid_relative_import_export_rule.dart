import "package:analysis_server_plugin/edit/dart/correction_producer.dart";
import "package:analyzer/analysis_rule/rule_context.dart";
import "package:analyzer/analysis_rule/rule_visitor_registry.dart";
import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/error/error.dart";
import "package:analyzer_plugin/utilities/change_builder/change_builder_core.dart";
import "package:analyzer_plugin/utilities/fixes/fixes.dart";
import "package:analyzer_plugin/utilities/range_factory.dart";

import "project_ast_visitor.dart";
import "project_dart_lint_rule.dart";

/// 相対パスのインポート・エクスポート回避ルール
///
/// 相対パスを用いたインポート・エクスポートを回避するためのルールです。
/// 絶対パスを使用してください(e.g. `import "/presentation/view/style/theme/theme.dart";`)。
/// ただし、`..`を一切含まない場合に限り相対パスで記述してください(e.g. `import "event.dart";`)。
class AvoidRelativeImportExportRule extends ProjectDartLintRule {
  AvoidRelativeImportExportRule() : super(name: "avoid_relative_import_export", description: "Use absolute paths or simple same-directory relative paths for import/export directives.");

  @override
  LintCode get diagnosticCode => const LintCode(
    "avoid_relative_import_export",
    "Use absolute paths or simple same-directory relative paths for import/export directives.",
    correctionMessage: "Use absolute path like '/presentation/view/...' or simple relative path like 'event.dart'.",
  );

  @override
  void registerProjectNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this);
    registry.addImportDirective(this, visitor);
    registry.addExportDirective(this, visitor);
  }
}

class _Visitor extends ProjectAstVisitor {
  _Visitor(super.rule);

  @override
  void visitImportDirective(ImportDirective node) => _check(node);

  @override
  void visitExportDirective(ExportDirective node) => _check(node);

  void _check(UriBasedDirective node) {
    if (!shouldLint(node)) return;

    final uri = node.uri.stringValue;
    if (uri == null) return;

    final isInvalidRelative = uri.startsWith("../") || uri.startsWith("./");
    if (isInvalidRelative) {
      rule.reportAtNode(node.uri);
    }
  }
}

/// ----- Fix -----

class AvoidRelativeImportExportFix extends ResolvedCorrectionProducer {
  AvoidRelativeImportExportFix({required super.context});

  static const _fixKind = FixKind("dart.fix.convertToAbsoluteImport", 50, "Convert to absolute import");

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final node = this.node;

    // SimpleStringLiteral を受け入れる
    if (node is! SimpleStringLiteral) return;

    final relativeUri = node.value;

    // 現在のファイルパスを取得
    final currentFilePath = file;

    // 絶対パスを計算
    final absolutePath = _resolveToAbsolutePath(currentFilePath, relativeUri);
    if (absolutePath == null) return;

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.node(node), '"$absolutePath"');
    });
  }

  /// 相対パスを絶対パスに変換
  ///
  /// currentFilePath: /Users/.../project/lib/presentation/view/foo/bar.dart
  /// relativeUri: ../baz/qux.dart
  /// → /presentation/view/baz/qux.dart
  String? _resolveToAbsolutePath(String currentFilePath, String relativeUri) {
    // /lib/ の位置を見つける
    final libIndex = currentFilePath.indexOf("/lib/");
    if (libIndex < 0) return null;

    // 現在のファイルをUriとして扱い、相対パスを解決
    // Uri.resolve() は現在のファイルからの相対パスを正しく解決する
    final currentFileUri = Uri.file(currentFilePath);
    final resolvedUri = currentFileUri.resolve(relativeUri);
    final resolvedPath = resolvedUri.toFilePath();

    // /lib/ 以降を抽出
    final resolvedLibIndex = resolvedPath.indexOf("/lib/");
    if (resolvedLibIndex < 0) return null;

    // /lib/ の後の部分を返す（先頭に / を付ける）
    return resolvedPath.substring(resolvedLibIndex + 4); // "/lib" の長さは 4
  }
}
