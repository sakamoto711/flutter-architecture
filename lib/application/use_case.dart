import "dart:async";

import "package:flutter/foundation.dart";

import "/application/outbound_port/domain_event_publisher.dart";
import "/common/class/exception/exception.dart";
import "/common/extension/object_extension.dart";
import "/common/logger/logger.dart";
import "/domain/shared/model/domain_object.dart";
import "input_port.dart";
import "output_port.dart";

export "/common/logger/logger.dart";
export "/domain/shared/model/domain_object.dart";
export "helper.dart";
export "input_port.dart";
export "output_port.dart";

/// ユースケース
@immutable
sealed class UseCase<P extends InputPortParameter, T> implements InputPort<P, T> {
  @protected
  final Logger logger;

  const UseCase({
    required this.logger,
  });

  /// 入力ポートの実行
  ///
  /// バリデーションを実行後に[execute]を実行します。
  /// 実行結果に応じて[OutputPort]の[onSuccess]または[onError]を呼び出します。
  @override
  @nonVirtual
  Future<void> perform(P parameter, OutputPort<T> outputPort) async {
    logger.debug(message: "ユースケースの実行を開始", context: Context({"useCase": runtimeType, "parameter": parameter}));
    late final T result;
    try {
      parameter.validate();
      result = await execute(parameter);
      logger.debug(message: "ユースケースの実行が完了", context: Context({"useCase": runtimeType, "result": result}));
    } catch (e, stackTrace) {
      logger.error(message: "ユースケースの実行で例外が発生", context: Context({"useCase": runtimeType, "parameter": parameter}), error: e, stackTrace: stackTrace);
      await outputPort.onError(e.asOrNull<Exception>() ?? UnexpectedThrowableException(e), stackTrace);
      return;
    }

    await outputPort.onSuccess(result);
  }

  /// ユースケースの実行
  ///
  /// ユースケースの実行を行います。
  @protected
  FutureOr<T> execute(P parameter);
}

/// クエリ
///
/// CQRSにおけるQueryに該当します。
/// 副作用のない処理を行います。
abstract class Query<P extends InputPortParameter, T> extends UseCase<P, T> {
  const Query({
    required super.logger,
  });

  @override
  @nonVirtual
  FutureOr<T> execute(P param) => query(param);

  @protected
  FutureOr<T> query(P param);
}

/// コマンド
///
/// CQRSにおけるCommandに該当します。
/// 副作用のある処理を行います。
sealed class Command<P extends InputPortParameter, T> extends UseCase<P, T> {
  @protected
  final DomainEventPublisher eventPublisher;

  const Command({
    required super.logger,
    required this.eventPublisher,
  });
}

/// コマンド(戻り値なし)
///
/// 戻り値を返却することは出来ません。
/// 失敗時は例外をthrowしてください。
abstract class VoidCommand<P extends InputPortParameter> extends Command<P, void> {
  const VoidCommand({
    required super.logger,
    required super.eventPublisher,
  });

  @override
  @nonVirtual
  FutureOr<void> execute(P param) => command(param);

  @protected
  FutureOr<void> command(P param);
}

/// コマンド(戻り値あり)
///
/// 生成されたドメインオブジェクトの識別子などの戻り値を返却することが出来ます。
/// 原則として識別子や識別子の配列を返却し、生成されたドメインオブジェクトそのものは返却しないようにしてください。
abstract class ValueCommand<P extends InputPortParameter, ID extends IdentifierGroup> extends Command<P, ID> {
  const ValueCommand({
    required super.logger,
    required super.eventPublisher,
  });

  @override
  @nonVirtual
  FutureOr<ID> execute(P param) => command(param);

  @protected
  FutureOr<ID> command(P param);
}
