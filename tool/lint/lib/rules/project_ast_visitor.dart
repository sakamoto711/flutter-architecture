import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/dart/ast/visitor.dart";
import "package:meta/meta.dart";

import "project_dart_lint_rule.dart";

/// プロジェクト固有のAstVisitor基底クラス
///
/// lib/配下のみを対象とし、test/やtool/、自動生成ファイルを除外する。
abstract class ProjectAstVisitor extends SimpleAstVisitor<void> {
  ProjectAstVisitor(this.rule);

  final ProjectDartLintRule rule;

  /// 除外ディレクトリ
  static const _excludedDirectories = {"/tool/", "/test/"};

  /// 自動生成ファイルの拡張子
  static const _generatedExtensions = {".g.dart", ".freezed.dart", ".gr.dart", ".config.dart"};

  /// テスト時にパスチェックをスキップするためのフラグ
  @visibleForTesting
  static bool skipPathCheck = false;

  /// ASTノードからファイルパスを取得する
  String? getFilePath(AstNode node) {
    final root = node.root;
    if (root is! CompilationUnit) return null;
    return root.declaredFragment?.source.fullName;
  }

  /// プロジェクト直下のlib/配下のファイルかどうかを判定する
  bool _isLibPath(String path) {
    if (_excludedDirectories.any(path.contains)) return false;
    return path.contains("/lib/");
  }

  /// 自動生成ファイルかどうかを判定する
  bool _isGeneratedFile(String path) {
    return _generatedExtensions.any(path.endsWith);
  }

  /// Lint対象のノードかどうかを判定する
  /// lib/配下かつ自動生成ファイルでない場合にtrue
  bool shouldLint(AstNode node) {
    if (skipPathCheck) return true;

    final path = getFilePath(node);
    if (path == null) return false;
    return _isLibPath(path) && !_isGeneratedFile(path);
  }
}
