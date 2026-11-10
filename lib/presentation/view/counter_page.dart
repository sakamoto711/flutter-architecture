import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "/presentation/bloc/counter/counter_bloc.dart";
import "/presentation/bloc/share/bloc/state.dart" as core;

class CounterPage extends StatelessWidget {
  const CounterPage({super.key, required this.createBloc});
  final CounterBloc Function() createBloc;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Counter")),
    body: Center(
      child: BlocBuilder<CounterBloc, CounterState>(
        builder: (context, state) {
          final data = switch (state) {
            core.DataHolding<CounterStateData>(:final data) => data,
            _ => null,
          };
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (data != null) Text("${data.counter.value}", key: const Key("counter-value"), style: Theme.of(context).textTheme.displayLarge),
              if (state is core.Loading) const CircularProgressIndicator(),
              if (state is core.Error) ...[
                const Text("読み込みまたは更新に失敗しました"),
              ],
              TextButton(onPressed: state is core.Loading ? null : () => context.read<CounterBloc>().add(const CounterRefreshRequested()), child: const Text("再読み込み")),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider(
                      create: (_) => createBloc()..requestInitialLoad(const CounterInitialLoadRequested()),
                      child: CounterPage(createBloc: createBloc),
                    ),
                  ),
                ),
                child: const Text("Open another screen"),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: data != null && state is! core.Loading ? () => context.read<CounterBloc>().add(const CounterIncrementRequested()) : null,
                child: const Text("+1"),
              ),
            ],
          );
        },
      ),
    ),
  );
}
