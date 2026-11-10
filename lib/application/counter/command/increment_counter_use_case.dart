import "/application/use_case.dart";
import "/domain/counter/counter_write_repository.dart";
import "/domain/counter/event/counter_changed.dart";

abstract interface class IncrementCounterInputPort implements InputPort<IncrementCounterInputPortParameter, void> {}

final class IncrementCounterUseCase extends VoidCommand<IncrementCounterInputPortParameter> implements IncrementCounterInputPort {
  final CounterWriteRepository _repository;

  const IncrementCounterUseCase({required this._repository, required super.logger, required super.eventPublisher});

  @override
  Future<void> command(IncrementCounterInputPortParameter param) async {
    await _repository.update((counter) => counter.increment());
    eventPublisher.publish(const CounterChanged());
  }
}

final class IncrementCounterInputPortParameter extends InputPortParameter {
  const IncrementCounterInputPortParameter();

  @override
  void validate() {}

  @override
  List<Object?> get props => [];
}
