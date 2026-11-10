import "/domain/counter/counter.dart";
import "/presentation/bloc/share/bloc/state_data.dart";

final class CounterStateData extends StateData {
  final Counter counter;
  const CounterStateData(this.counter);
  @override
  List<Object?> get props => [counter];
}
