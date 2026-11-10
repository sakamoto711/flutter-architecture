import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "/di/app_dependencies.dart";
import "/presentation/bloc/counter/counter_bloc.dart";
import "/presentation/view/component/bloc_view_builder.dart";
import "/presentation/view/counter_page.dart";

void main() {
  final dependencies = AppDependencies();
  runApp(CounterApp(createBloc: dependencies.createCounterBloc));
}

class CounterApp extends StatelessWidget {
  final CounterBloc Function() createBloc;
  const CounterApp({super.key, required this.createBloc});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: "Flutter Architecture",
    home: BlocViewBuilder<CounterBloc, CounterInitialLoadRequested, CounterState>(
      create: createBloc,
      initialLoadEvent: const CounterInitialLoadRequested(),
      builder: (context, bloc, state) => BlocProvider.value(
        value: bloc,
        child: CounterPage(createBloc: createBloc),
      ),
    ),
  );
}
