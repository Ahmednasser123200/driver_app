import 'dart:async';

import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_ui_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/base/base_cubit.dart';
import '../../../config/base/base_ui_event.dart';
import '../../../config/localization/app_failure_message_mapper.dart';
import '../../../l10n/generated/app_localizations.dart';

extension AppLocalizationsX on AppLocalizations {
  String get orderStatusUpdatedSuccessfully =>
      'Order status updated successfully';
}

class BaseUiEventListener<C extends BaseCubit<S, E>, S, E extends BaseUiEvent>
    extends StatefulWidget {
  const BaseUiEventListener({
    super.key,
    this.cubit,
    this.onCustomEvent,
    required this.child,
  });

  final C? cubit;
  final void Function(BuildContext context, E event)? onCustomEvent;
  final Widget child;

  @override
  State<BaseUiEventListener<C, S, E>> createState() =>
      _BaseUiEventListenerState<C, S, E>();
}

class _BaseUiEventListenerState<
  C extends BaseCubit<S, E>,
  S,
  E extends BaseUiEvent
>
    extends State<BaseUiEventListener<C, S, E>> {
  StreamSubscription<E>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant BaseUiEventListener<C, S, E> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.cubit != widget.cubit) {
      _unsubscribe();
      _subscribe();
    }
  }

  void _subscribe() {
    final targetCubit = widget.cubit ?? context.read<C>();

    _subscription = targetCubit.uiEventStream.listen((event) {
      if (mounted) {
        _handleEvent(context, event);
      }
    });
  }

  void _handleEvent(BuildContext context, E event) {
    switch (event) {
      case ShowSuccessMessage():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(event.message), backgroundColor: Colors.green),
        );

      case ShowErrorMessage():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(event.message), backgroundColor: Colors.red),
        );

      case NavigateTo():
        Navigator.of(
          context,
        ).pushNamed(event.routeName, arguments: event.arguments);

      case PopRoute():
        Navigator.of(context).pop(event.result);

      case ShowFailureMessage():
        final l10n = AppLocalizations.of(context)!;
        final message = mapAppFailureToMessage(event.failure, l10n);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );

      case ShowOrderStatusUpdated():
        final l10n = AppLocalizations.of(context)!;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.orderStatusUpdatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );

    
    }
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
  Widget build(BuildContext context) {
    return widget.child;
  }
}
