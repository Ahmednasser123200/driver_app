import 'dart:async';

import 'package:flutter/material.dart';

import '../../../config/base/base_cubit.dart';

class BaseUiEventListener<CubitState, UiEvent> extends StatefulWidget {
  const BaseUiEventListener({
    super.key,
    required this.cubit,
    required this.onEvent,
    required this.child,
  });

  final BaseCubit<CubitState, UiEvent> cubit;
  final void Function(BuildContext context, UiEvent event) onEvent;
  final Widget child;
  @override
  State<BaseUiEventListener<CubitState, UiEvent>> createState() =>
      _BaseUiEventListenerState<CubitState, UiEvent>();
}

class _BaseUiEventListenerState<CubitState, UiEvent>
    extends State<BaseUiEventListener<CubitState, UiEvent>> {
  StreamSubscription<UiEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(
    covariant BaseUiEventListener<CubitState, UiEvent> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cubit != widget.cubit) {
      _unsubscribe();
      _subscribe();
    }
  }

  void _subscribe() {
    _subscription = widget.cubit.uiEventStream.listen((event) {
      if (mounted) {
        widget.onEvent(context, event);
      }
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
