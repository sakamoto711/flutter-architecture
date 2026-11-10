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
    return isProjectLibPath(path, rule.packageRoot);
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

@visibleForTesting
bool isProjectLibPath(String path, String? packageRoot) {
  if (packageRoot == null) return false;
  final normalized = path.replaceAll(r"\", "/");
  final root = packageRoot.replaceAll(r"\", "/").replaceFirst(RegExp(r"/$"), "");
  return normalized.startsWith("$root/lib/");
}
