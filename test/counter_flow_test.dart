import "package:flutter/material.dart";
import "package:flutter_architecture/application/counter/command/increment_counter_use_case.dart";
import "package:flutter_architecture/application/counter/query/fetch_counter_use_case.dart";
import "package:flutter_architecture/application/helper.dart";
import "package:flutter_architecture/application/outbound_port/domain_event_publisher.dart";
import "package:flutter_architecture/common/logger/noop_logger.dart";
import "package:flutter_architecture/di/app_dependencies.dart";
import "package:flutter_architecture/domain/counter/counter.dart";
import "package:flutter_architecture/domain/counter/counter_write_repository.dart";
import "package:flutter_architecture/domain/shared/event/domain_event.dart";
import "package:flutter_architecture/main.dart";
import "package:flutter_architecture/presentation/bloc/counter/counter_bloc.dart";
import "package:flutter_architecture/presentation/bloc/share/bloc/state.dart" as core;
import "package:flutter_test/flutter_test.dart";

void main() {
  testWidgets("ボタン操作がRepositoryを更新し、DomainEvent経由で画面に反映される", (tester) async {
    final dependencies = AppDependencies();
    await tester.pumpWidget(CounterApp(createBloc: dependencies.createCounterBloc));
    await tester.pumpAndSettle();
    expect(find.text("0"), findsOneWidget);
    await tester.tap(find.text("+1"));
    await tester.pumpAndSettle();
    expect(find.text("1"), findsOneWidget);
    final counter = await InputPortInvoker(dependencies.fetchCounter).invoke(const FetchCounterInputPortParameter()).unwrapOrThrow();
    expect(counter.value, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test("UseCaseから発行されたイベントを複数のBLoCが受け取る", () async {
    final dependencies = AppDependencies();
    final first = dependencies.createCounterBloc();
    final second = dependencies.createCounterBloc();
    addTearDown(first.close);
    addTearDown(second.close);
    first.requestInitialLoad(const CounterInitialLoadRequested());
    second.requestInitialLoad(const CounterInitialLoadRequested());
    await Future.wait([_waitForValue(first, 0), _waitForValue(second, 0)]);
    final received = Future.wait([_waitForValue(first, 1), _waitForValue(second, 1)]);
    await InputPortInvoker(dependencies.incrementCounter).invoke(const IncrementCounterInputPortParameter()).unwrapOrThrow();
    await received;
  });

  test("連続した更新要求を逐次処理し、更新を失わない", () async {
    final dependencies = AppDependencies();
    final bloc = dependencies.createCounterBloc();
    addTearDown(bloc.close);
    bloc.requestInitialLoad(const CounterInitialLoadRequested());
    await _waitForValue(bloc, 0);
    final received = _waitForValue(bloc, 20);
    for (var i = 0; i < 20; i++) {
      bloc.add(const CounterIncrementRequested());
    }
    await received;
    final counter = await InputPortInvoker(dependencies.fetchCounter).invoke(const FetchCounterInputPortParameter()).unwrapOrThrow();
    expect(counter.value, 20);
  });

  test("close後のBLoCは購読を解除し、他のBLoCは更新を受信し続ける", () async {
    final dependencies = AppDependencies();
    final closed = dependencies.createCounterBloc();
    final active = dependencies.createCounterBloc();
    addTearDown(active.close);
    await closed.close();
    active.requestInitialLoad(const CounterInitialLoadRequested());
    await _waitForValue(active, 0);
    final received = _waitForValue(active, 1);
    final result = await InputPortInvoker(dependencies.incrementCounter).invoke(const IncrementCounterInputPortParameter());
    expect(result, isA<Success<void>>());
    await received;
    expect(closed.state, isA<CounterInitializeReadyState>());
  });

  test("保存失敗時にはDomainEventを送信しない", () async {
    final publisher = _RecordingPublisher();
    final useCase = IncrementCounterUseCase(repository: _FailingRepository(), logger: const NoopLogger(), eventPublisher: publisher);
    final result = await InputPortInvoker(useCase).invoke(const IncrementCounterInputPortParameter());
    expect(result, isA<Failure>());
    expect(publisher.events, isEmpty);
  });
}

Future<void> _waitForValue(CounterBloc bloc, int expected) async {
  bool matches(CounterState state) => state is core.DataHolding<CounterStateData> && (state as core.DataHolding<CounterStateData>).data.counter.value == expected && state is! core.Loading;
  if (matches(bloc.state)) return;
  await bloc.stream.firstWhere(matches).timeout(const Duration(seconds: 5));
}

class _RecordingPublisher implements DomainEventPublisher {
  final events = <DomainEvent>[];
  @override
  void publish(DomainEvent event) => events.add(event);
}

class _FailingRepository implements CounterWriteRepository {
  @override
  Future<void> update(Counter Function(Counter current) change) async => throw Exception("save failed");
}
