#!/usr/bin/env dart

import "dart:io";

import "package:mason/mason.dart";
import "package:path/path.dart" as path;

import "generator/use_case/mason_use_case.dart";

Future<void> main(List<String> args) async {
  try {
    if (args.length != 3) {
      stderr.writeln(
        "Usage: dart run tool/mason/generate_use_case.dart <UseCaseName> <query|command> <OutputDirectory>"
        "\n  Example: dart run tool/mason/generate_use_case.dart FetchUser query user",
      );
      throw Exception("Invalid arguments: must provide 3 arguments");
    }

    final useCaseName = MasonUseCaseName(args[0]);
    final type = MasonUseCaseType.valueOf(args[1]);
    final outputDirectoryName = MasonUseCaseOutputDirectoryName(args[2]);
    final outputDerectory = outputDirectoryName + "/${type.name}";

    final isQuery = type == MasonUseCaseType.query;
    final superClass = isQuery ? "Query<${useCaseName.pascalCase}InputPortParameter, Never>" : "VoidCommand<${useCaseName.pascalCase}InputPortParameter>";
    final methodName = isQuery ? "query" : "command";
    final returnType = isQuery ? "Never" : "void";

    // Load the brick
    final brickPath = path.join(path.dirname(path.fromUri(Platform.script)), "template", "use_case");
    final brick = Brick.path(brickPath);

    final generator = await MasonGenerator.fromBrick(brick);

    // Variables passed to the template
    final vars = <String, dynamic>{
      "name": useCaseName,
      "super_class": superClass,
      "method_name": methodName,
      "return_type": returnType,
      "output_directory": outputDerectory,
      "is_query": isQuery,
      "test_imports": ([
        'import "package:flutter_test/flutter_test.dart";',
        if (!isQuery) 'import "package:mocktail/mocktail.dart";',
        if (!isQuery) 'import "package:flutter_architecture/application/outbound_port/domain_event_publisher.dart";',
        'import "package:flutter_architecture/application/helper.dart";',
        'import "package:flutter_architecture/common/logger/noop_logger.dart";',
        'import "package:flutter_architecture/$outputDerectory/${useCaseName.snakeCase}_use_case.dart";',
      ]..sort()).join("\n"),
    };

    stdout.writeln('🚧  Generating ${type.name} UseCase "$useCaseName" ...');

    // プロジェクトルートに対して生成（テンプレート側で lib/test を切り分け）
    final projectRoot = Directory(path.normalize(path.join(path.dirname(path.fromUri(Platform.script)), "..", "..")));
    await generator.generate(DirectoryGeneratorTarget(projectRoot), vars: vars, logger: Logger(), fileConflictResolution: FileConflictResolution.skip);

    stdout.writeln("✅  Generated file in $outputDirectoryName");
  } catch (e, stackTrace) {
    stderr.writeln(e);
    stderr.writeln(stackTrace);
    exitCode = 64;
    return;
  }
}
