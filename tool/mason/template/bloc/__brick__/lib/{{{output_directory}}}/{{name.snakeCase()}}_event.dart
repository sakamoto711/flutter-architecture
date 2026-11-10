import "/presentation/bloc/share/bloc/bloc_event.dart";

// FIXME: [must-delete-this-comment] DartDocにBLoCの和名を記載してください(例: カテゴリー一覧BLoC)

/// BLoC - イベント
sealed class {{name.pascalCase()}}BlocEvent extends BlocEvent {
  const {{name.pascalCase()}}BlocEvent();
}

/// BLoC - 初期読込要求
class {{name.pascalCase()}}InitialLoadRequested extends {{name.pascalCase()}}BlocEvent implements InitialLoadRequested {
  const {{name.pascalCase()}}InitialLoadRequested();
}

// FIXME: [must-delete-this-comment] 必要なイベントを実装してください
