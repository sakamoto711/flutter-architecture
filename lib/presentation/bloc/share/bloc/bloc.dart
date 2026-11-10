import "package:flutter/foundation.dart";
import "package:flutter_bloc/flutter_bloc.dart" as original;

import "/common/extension/object_extension.dart";
import "/common/logger/logger.dart";
import "/common/typedef/future_or_typedef.dart";
import "/domain/shared/event/domain_event.dart";
import "/presentation/event/domain_event_subscriber.dart";
import "bloc_event.dart";
import "exception.dart";
import "state.dart";

export "package:flutter_bloc/flutter_bloc.dart" hide Bloc;

export "/common/logger/logger.dart";
export "/presentation/event/domain_event_subscriber.dart";
export "bloc_event.dart";
export "exception.dart";
export "state.dart";

/// Business Logic Component(BLoC)共通基底
///
/// 機能固有のsealedな[E]を一つの逐次キューで処理します。
abstract class BlocBase<E extends BlocEvent, S extends State, T extends StateData> extends original.Bloc<E, S> implements BlocViewModel<S>, DomainEventListener {
  @protected
  final DomainEventSubscriber eventSubscriber;
  final List<DomainEventBinding<E>> _domainEventBindings;

  @protected
  final Logger logger;

  BlocBase({
    required this.eventSubscriber,
    required this.logger,
    required S initialState,
    List<DomainEventBinding<E>> domainEventBindings = const [],
  }) : _domainEventBindings = List.unmodifiable(domainEventBindings),
       super(initialState) {
    super.on<E>(_runEventHandler, transformer: _sequential());
    eventSubscriber.addListener(this);
  }

  /// BLoCが受理するすべてのイベントを処理する。
  ///
  /// [E]のsealed classをswitchし、すべてのイベントを明示的に処理する。
  @protected
  FutureOr<void> handleEvent(E event, original.Emitter<S> emit);

  Future<void> _runEventHandler(E event, original.Emitter<S> emit) async {
    final initialState = state;
    try {
      await handleEvent(event, emit);
    } catch (error, stackTrace) {
      if (_leftNewLoading(initialState)) {
        _recoverFromLoading(error, emit);
      }
      await Future<void>.error(error, stackTrace);
    }

    if (!_leftNewLoading(initialState)) return;

    final error = EventHandlerCompletedInLoadingException(eventType: event.runtimeType);
    _recoverFromLoading(error, emit);
    await Future<void>.error(error, StackTrace.current);
  }

  bool _leftNewLoading(S initialState) {
    final currentState = state;
    return currentState is Loading && (initialState is! Loading || !identical(currentState, initialState));
  }

  void _recoverFromLoading(Object error, original.Emitter<S> emit) {
    final state = this.state;
    if (state is! Loading) return;

    final errorState = state.error(error);
    if (errorState case final S compatibleErrorState) {
      emit(compatibleErrorState);
      return;
    }

    throw StateError(
      "Loading.error returned ${errorState.runtimeType}, which is not assignable to $S",
    );
  }

  /// Event root以外のハンドラ登録を禁止する。
  ///
  /// Event handlerは基底クラスが一つだけ登録する。
  @override
  @nonVirtual
  void on<EventType extends E>(
    original.EventHandler<EventType, S> handler, {
    original.EventTransformer<EventType>? transformer,
  }) => throw UnsupportedError("BlocBase registers exactly one handler for its event root.");

  @override
  Future<void> close() async {
    eventSubscriber.removeListener(this);
    await super.close();
  }

  @override
  @nonVirtual
  bool isTarget(DomainEvent event) => _domainEventBindings.any((binding) => binding.matches(event));

  @override
  @nonVirtual
  void onDomainEvent(DomainEvent event) {
    final matchedBindings = _domainEventBindings.where((binding) => binding.matches(event)).toList(growable: false);
    if (matchedBindings.length != 1) {
      throw StateError("Expected exactly one DomainEventBinding for ${event.runtimeType}, but found ${matchedBindings.length}.");
    }

    add(matchedBindings.single.map(event));
  }
}

/// ViewがBLoCの状態購読と破棄に利用する契約
abstract interface class BlocViewModel<S extends State> implements original.StateStreamable<S> {
  Future<void> close();
}

/// Viewが初期ロードを要求できるBLoCの契約
abstract interface class InitialLoadBlocViewModel<I extends BlocEvent, S extends State> implements BlocViewModel<S> {
  void requestInitialLoad(I event);
}

/// 初期ロードを行うBLoC
abstract class Bloc<E extends BlocEvent, I extends E, S extends State, T extends StateData> extends BlocBase<E, S, T> implements InitialLoadBlocViewModel<I, S> {
  Bloc({
    required super.eventSubscriber,
    required super.logger,
    required super.initialState,
    super.domainEventBindings,
  });

  @override
  @nonVirtual
  void requestInitialLoad(I event) => add(event);

  /// 初期ロード要求を処理する。
  @protected
  FutureOr<void> initialize(I event, original.Emitter<S> emit) async {
    final state = this.state;
    switch (state) {
      case InitializeReady():
        await _initialLoadRequested(state, emit, () => handleInitialLoadRequested(event));
      default:
        throw IllegalStateException(actual: state, expected: InitializeReady);
    }
  }

  /// 初期ロードに必要なデータを返す。
  @protected
  FutureOr<T> handleInitialLoadRequested(I event);
}

/// 初期ロードを持たないBLoC
abstract class NoInitializationBloc<E extends BlocEvent, S extends State, T extends StateData> extends BlocBase<E, S, T> {
  NoInitializationBloc({
    required super.eventSubscriber,
    required super.logger,
    required super.initialState,
    super.domainEventBindings,
  });
}

/// Domain Eventを機能固有のBLoC Eventへ変換する規則
abstract interface class DomainEventBinding<E extends BlocEvent> {
  const DomainEventBinding();

  bool matches(DomainEvent event);

  E map(DomainEvent event);
}

/// [D]を`is`で判定して[E]へ変換するDomain Event binding
final class TypedDomainEventBinding<D extends DomainEvent, E extends BlocEvent> implements DomainEventBinding<E> {
  final E Function(D event) _mapper;

  const TypedDomainEventBinding(this._mapper);

  @override
  bool matches(DomainEvent event) => event is D;

  @override
  E map(DomainEvent event) => _mapper(event as D);
}

extension BlocExtension<E extends BlocEvent, S extends State, T extends StateData> on BlocBase<E, S, T> {
  VoidFutureOr _initialLoadRequested(S state, original.Emitter<State> emit, Action<T> action) async {
    if (state is! InitializeReady) {
      throw IllegalStateException(actual: state, expected: InitializeReady);
    }

    final loading = state.start();
    emit(loading);

    try {
      final result = await action();
      final complete = loading.complete(result);
      final shift = complete.shiftIfPossible<T>();
      emit(shift ?? complete);
    } catch (e, stackTrace) {
      logger.error(error: e, stackTrace: stackTrace);
      emit(loading.error(e));
    }
  }

  VoidFutureOr postInitialized<R>(S state, original.Emitter<State> emit, Action<R> action) async {
    final ready = state.toReady();
    final startableReady = ready?.asOrNull<StartableReady<PostInitializedLoading<T>>>();
    if (startableReady == null) {
      throw IllegalStateException(actual: state, expected: StartableReady<PostInitializedLoading<T>>);
    }

    final loading = startableReady.start();
    emit(loading);

    try {
      final result = await action();
      final complete = loading.next(result);
      emit(complete);
    } catch (e, stackTrace) {
      logger.error(error: e, stackTrace: stackTrace);
      emit(loading.error(e));
    }
  }
}

typedef Action<T> = FutureOr<T> Function();

extension on State {
  PostInitializedReady<T>? shiftIfPossible<T>() => asOrNull<ReadyShiftable<PostInitializedReady<T>>>()?.ready();

  // ignore: strict_raw_type
  PostInitializedReady? toReady() {
    final self = this;
    if (self is PostInitializedReady) return self;

    // ignore: strict_raw_type
    final readyShiftable = self.asOrNull<ReadyShiftable<PostInitializedReady>>();
    if (readyShiftable == null) {
      throw NotReadyShiftableException(state: self);
    }

    return readyShiftable.ready();
  }
}

original.EventTransformer<E> _sequential<E>() =>
    (events, mapper) => events.asyncExpand(mapper);
