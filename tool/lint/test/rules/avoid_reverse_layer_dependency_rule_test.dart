import "package:test/test.dart";
import "package:flutter_architecture_lint/rules/avoid_reverse_layer_dependency_rule.dart";

void main() {
  group("AvoidReverseLayerDependencyRule", () {
    test("[Positive] Infrastructureから通常のApplication実装への依存を拒否する", () {
      final result = isAllowedLayerImport(
        currentPath: "/project/lib/infrastructure/event/adapter.dart",
        importUri: "package:flutter_architecture/application/use_case.dart",
      );

      expect(result, isFalse);
    });

    test("[Negative] InfrastructureからApplicationの出力側ポートへの依存を許可する", () {
      final result = isAllowedLayerImport(
        currentPath: "/project/lib/infrastructure/event/adapter.dart",
        importUri: "package:flutter_architecture/application/outbound_port/domain_event_publisher.dart",
      );

      expect(result, isTrue);
    });

    test("[Negative] Applicationの結果通知用OutputPortは例外に含めない", () {
      final result = isAllowedLayerImport(
        currentPath: "/project/lib/infrastructure/event/adapter.dart",
        importUri: "package:flutter_architecture/application/output_port.dart",
      );

      expect(result, isFalse);
    });

    test("[Negative] 通常の依存方向を維持する", () {
      expect(
        isAllowedLayerImport(
          currentPath: "/project/lib/application/use_case.dart",
          importUri: "package:flutter_architecture/domain/model.dart",
        ),
        isTrue,
      );
      expect(
        isAllowedLayerImport(
          currentPath: "/project/lib/domain/model.dart",
          importUri: "package:flutter_architecture/application/use_case.dart",
        ),
        isFalse,
      );
    });
  });
}
