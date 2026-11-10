#!/usr/bin/env dart

import "dart:io";

import "package:mason/mason.dart";
import "package:path/path.dart" as path;

import "generator/bloc/mason_bloc.dart";

Future<void> main(List<String> args) async {
  try {
    if (args.length != 2) {
      stderr.writeln(
        "Usage: dart run tool/mason/generate_bloc.dart <BlocName> <OutputDirectory>"
        "\n  Example: dart run tool/mason/generate_bloc.dart OrderHistory order/order_history",
      );
      throw Exception("Invalid arguments must be 2 arguments");
    }

    final name = MasonBlocName(args[0]);
    final outputDirectoryName = MasonBlocOutputDirectoryName(args[1]);

    // Load the brick
    final brickPath = path.join(path.dirname(path.fromUri(Platform.script)), "template", "bloc");
    final brick = Brick.path(brickPath);

    final generator = await MasonGenerator.fromBrick(brick);

    // Variables passed to the template
    final vars = <String, dynamic>{
      "name": name,
      "output_directory": outputDirectoryName,
      "test_imports": ([
        'import "package:bloc_test/bloc_test.dart";',
        'import "package:flutter_test/flutter_test.dart";',
        'import "package:mocktail/mocktail.dart";',
        'import "package:flutter_architecture/common/logger/noop_logger.dart";',
        'import "package:flutter_architecture/$outputDirectoryName/${name.snakeCase}_bloc.dart";',
      ]..sort()).join("\n"),
    };

    stdout.writeln('🚧  Generating BLoC files for "$name" ...');

    // プロジェクトルートに対して生成（テンプレート側で lib/test を切り分け）
    final projectRoot = Directory(
      path.normalize(path.join(path.dirname(path.fromUri(Platform.script)), "..", "..")),
    );
    await generator.generate(
      DirectoryGeneratorTarget(projectRoot),
      vars: vars,
      logger: Logger(),
      fileConflictResolution: FileConflictResolution.skip,
    );

    stdout.writeln("✅  Generated file in $outputDirectoryName");
  } catch (e, stackTrace) {
    stderr.writeln(e);
    stderr.writeln(stackTrace);
    exitCode = 64;
    return;
  }
}
