import "dart:async";

import "/domain/shared/repository/write/write_repository.dart";
import "counter.dart";

abstract interface class CounterWriteRepository implements WriteRepository {
  /// 現在値を読み、更新して保存する操作を不可分に実行する。
  FutureOr<void> update(Counter Function(Counter current) change);
}
