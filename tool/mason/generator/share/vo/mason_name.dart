extension type MasonName._(String _value) implements String {
  factory MasonName(String value) {
    final trimmed = value.trim();
    validate(trimmed);
    return MasonName._(trimmed);
  }

  static void validate(String value) {
    if (!RegExp(r"^[A-Z][a-zA-Z0-9]*$").hasMatch(value)) {
      throw FormatException("Name must be a PascalCase Dart identifier", value, 0);
    }
  }
}
