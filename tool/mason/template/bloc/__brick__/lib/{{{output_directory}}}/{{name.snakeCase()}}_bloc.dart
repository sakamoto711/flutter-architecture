import "/common/typedef/future_or_typedef.dart";
import "/presentation/bloc/share/bloc/bloc.dart";
import "{{name.snakeCase()}}_event.dart";
import "{{name.snakeCase()}}_state.dart";

export "/presentation/bloc/share/bloc/bloc.dart";
export "{{name.snakeCase()}}_event.dart";
export "{{name.snakeCase()}}_state.dart";

// FIXME: [must-delete-this-comment] DartDocにBLoCの和名を記載してください(例: カテゴリー一覧BLoC)

/// BLoC
class {{name.pascalCase()}}Bloc extends Bloc<
  {{name.pascalCase()}}BlocEvent,
  {{name.pascalCase()}}InitialLoadRequested,
  {{name.pascalCase()}}State,
  {{name.pascalCase()}}StateData
> {
  {{name.pascalCase()}}Bloc({
    required super.eventSubscriber,
    required super.logger,
    super.domainEventBindings,
  }) : super(initialState: {{name.pascalCase()}}InitializeReadyState());

  @override
  FutureOr<void> handleEvent({{name.pascalCase()}}BlocEvent event, Emitter<{{name.pascalCase()}}State> emit) => switch (event) {
    {{name.pascalCase()}}InitialLoadRequested() => initialize(event, emit),
    // FIXME: [must-delete-this-comment] イベントを受信した時の処理を実装してください
  };

  @override
  FutureOr<{{name.pascalCase()}}StateData> handleInitialLoadRequested({{name.pascalCase()}}InitialLoadRequested event) async {
    // FIXME: [must-delete-this-comment] 初期化ロジックを実装してください
    return const {{name.pascalCase()}}StateData();
  }
}
