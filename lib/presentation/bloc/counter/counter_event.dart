import "/presentation/bloc/share/bloc/bloc_event.dart";

sealed class CounterBlocEvent extends BlocEvent {
  const CounterBlocEvent();
}

final class CounterInitialLoadRequested extends CounterBlocEvent implements InitialLoadRequested {
  const CounterInitialLoadRequested();
}

final class CounterIncrementRequested extends CounterBlocEvent {
  const CounterIncrementRequested();
}

final class CounterRefreshRequested extends CounterBlocEvent {
  const CounterRefreshRequested();
}
