enum MasonUseCaseType {
  query,
  command,
  ;

  static MasonUseCaseType valueOf(String value) =>
      MasonUseCaseType.values.firstWhere((e) => e.name == value.toLowerCase(), orElse: () => throw FormatException("UseCaseType must be 'query' or 'command'", value));
}
