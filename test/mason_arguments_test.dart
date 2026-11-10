import "package:flutter_test/flutter_test.dart";

import "../tool/mason/generator/bloc/mason_bloc.dart";
import "../tool/mason/generator/use_case/mason_use_case.dart";

void main() {
  test("queryやcommandを含む機能名を受け付ける", () {
    expect(MasonUseCaseOutputDirectoryName("search_query"), "application/search_query");
    expect(MasonUseCaseOutputDirectoryName("remote_command"), "application/remote_command");
    expect(() => MasonUseCaseOutputDirectoryName("feature/query"), throwsFormatException);
    expect(() => MasonUseCaseOutputDirectoryName("feature/command"), throwsFormatException);
  });

  test("Dart識別子と相対ディレクトリ以外を生成先に使わない", () {
    expect(() => MasonBlocName("Bad-Name"), throwsFormatException);
    expect(() => MasonBlocOutputDirectoryName("../outside"), throwsFormatException);
    expect(() => MasonUseCaseOutputDirectoryName("/outside"), throwsFormatException);
    expect(() => MasonBlocOutputDirectoryName(""), throwsFormatException);
  });
}
