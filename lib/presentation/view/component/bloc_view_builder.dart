import "dart:async";

import "package:flutter/widgets.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "/presentation/bloc/share/bloc/bloc.dart" as base;

/// 生成、初期ロード、購読、破棄を画面のライフサイクルに合わせる。
class BlocViewBuilder<B extends base.InitialLoadBlocViewModel<I, S>, I extends base.InitialLoadRequested, S extends base.State> extends StatefulWidget {
  const BlocViewBuilder({
    super.key,
    required this.create,
    required this.initialLoadEvent,
    required this.builder,
  });
  final B Function() create;
  final I initialLoadEvent;
  final Widget Function(BuildContext, B, S) builder;
  @override
  State<BlocViewBuilder<B, I, S>> createState() => _ViewState<B, I, S>();
}

class _ViewState<B extends base.InitialLoadBlocViewModel<I, S>, I extends base.InitialLoadRequested, S extends base.State> extends State<BlocViewBuilder<B, I, S>> {
  late final B bloc;
  @override
  void initState() {
    super.initState();
    bloc = widget.create();
    bloc.requestInitialLoad(widget.initialLoadEvent);
  }

  @override
  void dispose() {
    unawaited(bloc.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<B, S>(
    bloc: bloc,
    builder: (context, state) => widget.builder(context, bloc, state),
  );
}
