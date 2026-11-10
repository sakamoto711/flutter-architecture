import "../../share/vo/mason_output_directory.dart";

extension type MasonBlocOutputDirectoryName._(MasonOutputDirectoryName _value) implements MasonOutputDirectoryName {
  static final _prefix = "presentation/bloc/";

  factory MasonBlocOutputDirectoryName(String value) {
    MasonOutputDirectoryName.validate(value);
    validate(value);
    return MasonBlocOutputDirectoryName._(MasonOutputDirectoryName("$_prefix$value"));
  }

  static void validate(String value) {
    if (value.startsWith("/")) {
      throw FormatException("OutputDirectory must not start with '/'", value, value.indexOf("/"));
    }

    if (value.startsWith(_prefix)) {
      throw FormatException("OutputDirectory must be relative to '$_prefix' (prefix is added automatically)", value, value.indexOf(_prefix));
    }
  }
}
