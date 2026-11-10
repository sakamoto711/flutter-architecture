import "package:analysis_server_plugin/plugin.dart";
import "package:analysis_server_plugin/registry.dart";

import "rules/avoid_await_in_future_parallel_rule.dart";
import "rules/avoid_deserialize_only_outside_data_source_rule.dart";
import "rules/avoid_null_force_unwrap_rule.dart";
import "rules/avoid_relative_import_export_rule.dart";
import "rules/avoid_reverse_layer_dependency_rule.dart";
import "rules/avoid_serialize_only_outside_data_source_rule.dart";
import "rules/avoid_unnecessary_explicit_type_rule.dart";
import "rules/avoid_unused_transaction_runner_rule.dart";
import "rules/avoid_write_repository_in_query_rule.dart";
import "rules/missing_build_context_in_screen_event_handler_rule.dart";
import "rules/missing_field_in_props_rule.dart";
import "rules/prefer_record_type_for_future_parallel_rule.dart";

/// プラグインのトップレベル変数（必須）
final plugin = ArchitectureLintPlugin();

class ArchitectureLintPlugin extends Plugin {
  @override
  String get name => "flutter_architecture_lint";

  @override
  void register(PluginRegistry registry) {
    // Lint Rules
    final avoidAwaitInFutureParallelRule = AvoidAwaitInFutureParallelRule();
    final avoidUnnecessaryExplicitTypeRule = AvoidUnnecessaryExplicitTypeRule();
    final avoidRelativeImportExportRule = AvoidRelativeImportExportRule();
    final missingBuildContextInScreenEventHandlerRule = MissingBuildContextInScreenEventHandlerRule();
    final missingFieldInPropsRule = MissingFieldInPropsRule();

    registry.registerLintRule(avoidAwaitInFutureParallelRule);
    registry.registerLintRule(AvoidDeserializeOnlyOutsideDataSourceRule());
    registry.registerLintRule(AvoidNullForceUnwrapRule());
    registry.registerLintRule(avoidRelativeImportExportRule);
    registry.registerLintRule(AvoidReverseLayerDependencyRule());
    registry.registerLintRule(AvoidSerializeOnlyOutsideDataSourceRule());
    registry.registerLintRule(avoidUnnecessaryExplicitTypeRule);
    registry.registerLintRule(AvoidUnusedTransactionRunnerRule());
    registry.registerLintRule(AvoidWriteRepositoryInQueryRule());
    registry.registerLintRule(missingBuildContextInScreenEventHandlerRule);
    registry.registerLintRule(missingFieldInPropsRule);
    registry.registerLintRule(PreferRecordTypeForFutureParallelRule());

    // Fixes
    registry.registerFixForRule(avoidAwaitInFutureParallelRule.diagnosticCode, AvoidAwaitInFutureParallelFix.new);
    registry.registerFixForRule(avoidUnnecessaryExplicitTypeRule.diagnosticCode, AvoidUnnecessaryExplicitTypeFix.new);
    registry.registerFixForRule(avoidRelativeImportExportRule.diagnosticCode, AvoidRelativeImportExportFix.new);
    registry.registerFixForRule(missingBuildContextInScreenEventHandlerRule.diagnosticCode, MissingBuildContextInScreenEventHandlerFix.new);
    registry.registerFixForRule(missingFieldInPropsRule.diagnosticCode, MissingFieldInPropsFix.new);
  }
}
