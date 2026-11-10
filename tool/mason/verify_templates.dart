import "dart:io";

import "package:path/path.dart" as path;

Future<void> main() async {
  final root = Directory.current;
  final workspace = await Directory.systemTemp.createTemp("architecture-mason-");
  Future<void> run(String executable, List<String> args, {String? directory}) async {
    if (Platform.environment["CI"] == "true" && executable == "asdf") {
      executable = args[1];
      args = args.sublist(2);
    }
    final process = await Process.start(executable, args, workingDirectory: directory ?? workspace.path, mode: ProcessStartMode.inheritStdio);
    final code = await process.exitCode;
    if (code != 0) throw ProcessException(executable, args, "Template verification failed", code);
  }

  try {
    final listed = await Process.run("git", ["ls-files", "--cached", "--others", "--exclude-standard"], workingDirectory: root.path);
    if (listed.exitCode != 0) throw StateError("Cannot enumerate source files");
    for (final relative in (listed.stdout as String).split("\n").where((value) => value.isNotEmpty)) {
      final source = File(path.join(root.path, relative));
      if (!source.existsSync()) continue;
      final target = File(path.join(workspace.path, relative));
      await target.parent.create(recursive: true);
      await source.copy(target.path);
    }
    await run("asdf", ["exec", "flutter", "pub", "get", "--enforce-lockfile"]);
    await run("asdf", ["exec", "dart", "pub", "get", "--enforce-lockfile"], directory: path.join(workspace.path, "tool", "lint"));
    await run("asdf", ["exec", "dart", "run", "tool/mason/generate_bloc.dart", "TemplateCheck", "template_check"]);
    await run("asdf", ["exec", "dart", "run", "tool/mason/generate_use_case.dart", "FetchTemplateCheck", "query", "template_check"]);
    await run("asdf", ["exec", "dart", "run", "tool/mason/generate_use_case.dart", "SaveTemplateCheck", "command", "template_check"]);
    await run("asdf", [
      "exec",
      "flutter",
      "analyze",
      "--no-pub",
      "lib/presentation/bloc/template_check",
      "lib/application/template_check",
      "test/presentation/bloc/template_check",
      "test/application/template_check",
    ]);
    await run("asdf", ["exec", "flutter", "test", "--no-pub", "test/presentation/bloc/template_check", "test/application/template_check"]);
  } finally {
    await workspace.delete(recursive: true);
  }
}
