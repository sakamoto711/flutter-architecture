import "/domain/counter/counter.dart";
import "/domain/counter/counter_read_repository.dart";
import "/domain/counter/counter_write_repository.dart";

/// プロセス内だけで値を保持するサンプル実装。
final class InMemoryCounterRepository implements CounterReadRepository, CounterWriteRepository {
  Counter _counter = const Counter(0);

  @override
  Counter fetch() => _counter;

  @override
  void update(Counter Function(Counter current) change) {
    _counter = change(_counter);
  }
}
