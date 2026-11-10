import "package:analyzer/analysis_rule/rule_context.dart";
import "package:analyzer/analysis_rule/rule_visitor_registry.dart";
import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/dart/element/element.dart";
import "package:analyzer/error/error.dart";
import "package:meta/meta.dart";

import "project_ast_visitor.dart";
import "project_dart_lint_rule.dart";

/// レイヤ依存方向違反回避ルール
///
/// レイヤ依存方向の違反を回避するためのルールです。
/// 依存方向が逆転している場合にはエラーとします。
class AvoidReverseLayerDependencyRule extends ProjectDartLintRule {
  AvoidReverseLayerDependencyRule()
    : super(
        name: "avoid_reverse_layer_dependency",
        description: "Import or export violates the allowed direction of layer dependencies.",
      );

  @override
  LintCode get diagnosticCode => const LintCode(
    "avoid_reverse_layer_dependency",
    "Import or export violates the allowed direction of layer dependencies.",
    correctionMessage: "Check the layer dependency rules and fix the import or export.",
  );

  @override
  void registerProjectNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this);
    registry.addImportDirective(this, visitor);
    registry.addExportDirective(this, visitor);
  }
}

class _Visitor extends ProjectAstVisitor {
  _Visitor(super.rule);
  static final _allowed = <_Layer>{
    _Presentation(),
    _Application(),
    _Domain(),
    _Infrastructure(),
    _Common(),
  };

  static _Layer? _findLayer(_LayerEnum self) {
    for (final layer in _allowed) {
      if (layer.self == self) return layer;
    }
    return null;
  }

  @override
  void visitImportDirective(ImportDirective node) {
    _checkDirective(
      node,
      node.libraryImport?.importedLibrary,
      node.libraryImport?.namespace.definedNames2 ?? {},
    );
  }

  @override
  void visitExportDirective(ExportDirective node) {
    final library = node.libraryExport?.exportedLibrary;
    _checkDirective(
      node,
      library,
      library?.exportNamespace.definedNames2 ?? {},
    );
  }

  void _checkDirective(
    NamespaceDirective node,
    LibraryElement? library,
    Map<String, Element> names,
  ) {
    if (!shouldLint(node)) return;
    final path = getFilePath(node) ?? "";
    if (_LayerEnum.fromPath(path) == null) return;

    bool isForbidden(String uri) => !isAllowedLayerImport(currentPath: path, importUri: uri);

    final libRoot = path.substring(0, path.indexOf("/lib/") + 5);
    bool isForbiddenLibrary(LibraryElement? target) {
      final targetPath = target?.firstFragment.source.fullName;
      return targetPath != null && targetPath.startsWith(libRoot) && isForbidden(targetPath);
    }

    // Check every explicitly named branch, including inactive configurations.
    for (final uri in [node.uri, ...node.configurations.map((c) => c.uri)]) {
      if (isForbidden(uri.stringValue ?? "")) {
        rule.reportAtNode(uri);
        return;
      }
    }
    if (isForbiddenLibrary(library)) {
      rule.reportAtNode(node.uri);
      return;
    }

    // The analyzer has already followed transitive exports and export cycles.
    // Apply this directive's combinators before checking declaration origins.
    for (final entry in names.entries) {
      final name = entry.key.endsWith("=") ? entry.key.substring(0, entry.key.length - 1) : entry.key;
      if (!_isVisible(name, node.combinators)) continue;
      if (isForbiddenLibrary(entry.value.library)) {
        rule.reportAtNode(node.uri);
        return;
      }
    }
  }

  bool _isVisible(String name, Iterable<Combinator> combinators) {
    for (final combinator in combinators) {
      if (combinator is ShowCombinator && !combinator.shownNames.any((identifier) => identifier.name == name)) {
        return false;
      }
      if (combinator is HideCombinator && combinator.hiddenNames.any((identifier) => identifier.name == name)) {
        return false;
      }
    }
    return true;
  }
}

@visibleForTesting
bool isAllowedLayerImport({
  required String currentPath,
  required String importUri,
}) {
  final currentLayer = _LayerEnum.fromPath(currentPath);
  final importedLayer = _LayerEnum.fromPath(importUri);
  if (currentLayer == null || importedLayer == null) return true;

  if (currentLayer == _LayerEnum.infrastructure && importedLayer == _LayerEnum.application && importUri.contains("/application/outbound_port/")) {
    return true;
  }

  return _Visitor._findLayer(currentLayer)?.isReferenceable(importedLayer) ?? true;
}

enum _LayerEnum {
  presentation,
  application,
  domain,
  infrastructure,
  common;

  static _LayerEnum? fromPath(String path) {
    for (final layer in _LayerEnum.values) {
      if (path.contains("/$layer/")) return layer;
    }
    return null;
  }

  @override
  String toString() => name;
}

sealed class _Layer {
  _LayerEnum get self;
  Set<_LayerEnum> get _referenceable;

  bool isReferenceable(_LayerEnum layer) => layer == self || _referenceable.contains(layer);
}

class _Presentation extends _Layer {
  @override
  _LayerEnum get self => _LayerEnum.presentation;
  @override
  Set<_LayerEnum> get _referenceable => {
    _LayerEnum.application,
    _LayerEnum.domain,
    _LayerEnum.common,
  };
}

class _Application extends _Layer {
  @override
  _LayerEnum get self => _LayerEnum.application;
  @override
  Set<_LayerEnum> get _referenceable => {_LayerEnum.domain, _LayerEnum.common};
}

class _Domain extends _Layer {
  @override
  _LayerEnum get self => _LayerEnum.domain;
  @override
  Set<_LayerEnum> get _referenceable => {_LayerEnum.common};
}

class _Infrastructure extends _Layer {
  @override
  _LayerEnum get self => _LayerEnum.infrastructure;
  @override
  Set<_LayerEnum> get _referenceable => {_LayerEnum.domain, _LayerEnum.common};
}

class _Common extends _Layer {
  @override
  _LayerEnum get self => _LayerEnum.common;
  @override
  Set<_LayerEnum> get _referenceable => {_LayerEnum.common};
}
