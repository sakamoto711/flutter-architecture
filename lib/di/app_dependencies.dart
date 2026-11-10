import "/application/counter/command/increment_counter_use_case.dart";
import "/application/counter/query/fetch_counter_use_case.dart";
import "/common/logger/console_logger.dart";
import "/infrastructure/event/domain_event_publisher_impl.dart";
import "/infrastructure/event/event_bus_impl.dart";
import "/infrastructure/event/event_publisher_impl.dart";
import "/infrastructure/event/event_subscriber_impl.dart";
import "/infrastructure/repository/counter/in_memory_counter_repository.dart";
import "/presentation/bloc/counter/counter_bloc.dart";
import "/presentation/event/domain_event_subscriber_impl.dart";

/// 同じRepositoryとEventBusを使って各層を接続するComposition Root。
final class AppDependencies {
  final _repository = InMemoryCounterRepository();
  late final _eventBus = EventBusImpl(logger: _logger);
  final _logger = const ConsoleLogger();

  late final _publisher = DomainEventPublisherImpl(EventPublisherImpl(_eventBus));
  late final _subscriber = DomainEventSubscriberImpl(EventSubscriberImpl(_eventBus));
  late final FetchCounterInputPort fetchCounter = FetchCounterUseCase(repository: _repository, logger: _logger);
  late final IncrementCounterInputPort incrementCounter = IncrementCounterUseCase(repository: _repository, logger: _logger, eventPublisher: _publisher);

  /// 呼び出し側がBLoCを所有し、使用後にcloseする。
  CounterBloc createCounterBloc() => CounterBloc(fetchCounter: fetchCounter, incrementCounter: incrementCounter, eventSubscriber: _subscriber, logger: _logger);
}
