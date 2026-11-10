{{{test_imports}}}

class _Subscriber extends Mock implements DomainEventSubscriber {}

void main() {
  blocTest<{{name.pascalCase()}}Bloc, {{name.pascalCase()}}State>(
    "初期ロードを完了する",
    build: () => {{name.pascalCase()}}Bloc(eventSubscriber: _Subscriber(), logger: const NoopLogger()),
    act: (bloc) => bloc.requestInitialLoad(const {{name.pascalCase()}}InitialLoadRequested()),
    expect: () => [isA<{{name.pascalCase()}}InitializeLoadingState>(), isA<{{name.pascalCase()}}PostInitializedReadyState>()],
  );
}
