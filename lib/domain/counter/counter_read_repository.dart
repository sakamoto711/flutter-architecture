import "dart:async";

import "/domain/shared/repository/read/read_repository.dart";
import "counter.dart";

abstract interface class CounterReadRepository implements ReadRepository {
  FutureOr<Counter> fetch();
}
