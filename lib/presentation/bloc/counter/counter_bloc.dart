import "dart:async";

import "/application/counter/command/increment_counter_use_case.dart";
import "/application/counter/query/fetch_counter_use_case.dart";
import "/application/helper.dart";
import "/domain/counter/event/counter_changed.dart";
import "/presentation/bloc/share/bloc/bloc.dart";
import "counter_event.dart";
import "counter_state.dart";

export "counter_event.dart";
export "counter_state.dart";

final class CounterBloc extends Bloc<CounterBlocEvent, CounterInitialLoadRequested, CounterState, CounterStateData> {
  final FetchCounterInputPort _fetchCounter;
  final IncrementCounterInputPort _incrementCounter;

  CounterBloc({required this._fetchCounter, required this._incrementCounter, required super.eventSubscriber, required super.logger})
    : super(
        initialState: CounterInitializeReadyState(),
        domainEventBindings: [
          TypedDomainEventBinding<CounterChanged, CounterBlocEvent>((event) => const CounterRefreshRequested()),
        ],
      );

  @override
  FutureOr<void> handleEvent(CounterBlocEvent event, Emitter<CounterState> emit) => switch (event) {
    CounterInitialLoadRequested() || CounterRefreshRequested() => _load(emit),
    CounterIncrementRequested() => postInitialized(state, emit, () async {
      // 表示値の再取得は、保存後に届くCounterChangedから行う。
      await InputPortInvoker(_incrementCounter).invoke(const IncrementCounterInputPortParameter()).unwrapOrThrow();
    }),
  };

  Future<void> _load(Emitter<CounterState> emit) async {
    if (state is Initialize) {
      emit(CounterInitializeReadyState());
      await initialize(const CounterInitialLoadRequested(), emit);
      return;
    }
    await postInitialized(state, emit, _fetchData);
  }

  @override
  Future<CounterStateData> handleInitialLoadRequested(CounterInitialLoadRequested event) => _fetchData();

  Future<CounterStateData> _fetchData() async {
    final counter = await InputPortInvoker(_fetchCounter).invoke(const FetchCounterInputPortParameter()).unwrapOrThrow();
    return CounterStateData(counter);
  }
}
