import "/application/use_case.dart";
import "/domain/counter/counter.dart";
import "/domain/counter/counter_read_repository.dart";

abstract interface class FetchCounterInputPort implements InputPort<FetchCounterInputPortParameter, Counter> {}

final class FetchCounterUseCase extends Query<FetchCounterInputPortParameter, Counter> implements FetchCounterInputPort {
  final CounterReadRepository _repository;

  const FetchCounterUseCase({required this._repository, required super.logger});

  @override
  Future<Counter> query(FetchCounterInputPortParameter param) async => _repository.fetch();
}

final class FetchCounterInputPortParameter extends InputPortParameter {
  const FetchCounterInputPortParameter();

  @override
  void validate() {}

  @override
  List<Object?> get props => [];
}
