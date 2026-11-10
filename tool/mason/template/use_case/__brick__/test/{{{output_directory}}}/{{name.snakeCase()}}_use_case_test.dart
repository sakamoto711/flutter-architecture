{{{test_imports}}}

{{^is_query}}
class _Publisher extends Mock implements DomainEventPublisher {}
{{/is_query}}

void main() {
  test("未実装の処理をFailureとして返す（実装時に期待値を変更する）", () async {
    {{#is_query}}const{{/is_query}}{{^is_query}}final{{/is_query}} useCase = {{name.pascalCase()}}UseCase(
      logger: {{^is_query}}const {{/is_query}}NoopLogger(),
{{^is_query}}
      eventPublisher: _Publisher(),
{{/is_query}}
    );
    final result = await {{#is_query}}const {{/is_query}}InputPortInvoker(useCase).invoke(const {{name.pascalCase()}}InputPortParameter());
    expect(result, isA<Failure>());
  });
}
