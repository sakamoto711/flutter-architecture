extension type MasonOutputDirectoryName._(String _value) implements String {
  factory MasonOutputDirectoryName(String value) {
    validate(value);
    return MasonOutputDirectoryName._(value);
  }

  static void validate(String value) {
    if (!RegExp(r"^[a-z][a-z0-9_]*(/[a-z][a-z0-9_]*)*$").hasMatch(value)) {
      throw FormatException("OutputDirectory must contain lowercase directory names separated by '/'", value);
    }
  }
}
