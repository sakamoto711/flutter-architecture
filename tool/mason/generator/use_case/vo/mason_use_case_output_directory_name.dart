import "../../share/vo/mason_output_directory.dart";
import "mason_use_case_type.dart";

extension type MasonUseCaseOutputDirectoryName._(MasonOutputDirectoryName _value) implements MasonOutputDirectoryName {
  static final _prefix = "application/";

  factory MasonUseCaseOutputDirectoryName(String value) {
    MasonOutputDirectoryName.validate(value);
    validate(value);
    return MasonUseCaseOutputDirectoryName._(MasonOutputDirectoryName("$_prefix$value"));
  }

  static void validate(String value) {
    if (value.startsWith("/")) {
      throw FormatException("OutputDirectory must not start with '/'", value, value.indexOf("/"));
    }

    if (value.startsWith(_prefix)) {
      throw FormatException("OutputDirectory must be relative to '$_prefix' (prefix is added automatically)", value, value.indexOf(_prefix));
    }

    if (value.endsWith("/")) {
      throw FormatException("OutputDirectory must not end with '/'", value, value.length - 1);
    }

    final suffixList = MasonUseCaseType.values.map((e) => e.name);
    if (suffixList.contains(value.split("/").last)) {
      throw FormatException("OutputDirectory must not end with ${suffixList.join(" or ")}", value, value.length - value.split("/").last.length);
    }
  }
}
