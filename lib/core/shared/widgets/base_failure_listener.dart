import 'dart:async';

import 'package:flutter/material.dart';

import '../../../config/base/base_cubit.dart';
import '../../../config/errors/app_failure.dart';
import '../../../config/localization/app_failure_message_mapper.dart';
import '../../../l10n/generated/app_localizations.dart';

class BaseFailureListener<T> extends StatefulWidget {
  const BaseFailureListener({
    super.key,
    required this.cubit,
    required this.child,
  });

  final BaseCubit<T> cubit;
  final Widget child;

  @override
  State<BaseFailureListener<T>> createState() => _BaseFailureListenerState<T>();
}

class _BaseFailureListenerState<T> extends State<BaseFailureListener<T>> {
  StreamSubscription<AppFailure>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.cubit.uiEventStream.listen(_handleFailure);
  }

  @override
  void didUpdateWidget(covariant BaseFailureListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cubit != widget.cubit) {
      _subscription?.cancel();
      _subscription = widget.cubit.uiEventStream.listen(_handleFailure);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _handleFailure(AppFailure failure) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(mapAppFailureToMessage(failure, l10n))),
      );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
