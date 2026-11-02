import 'dart:async';

import 'package:driver_app/config/localization/app_failure_message_mapper.dart';
import 'package:driver_app/config/localization/handle_success_text.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/base/base_cubit.dart';
import '../../../config/base/base_ui_event.dart';
import '../../themes/app_colors/app_colors.dart';

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
        final message = switch (event.message) {
          AppSuccessEnum value => handleSuccessText(
            AppLocalizations.of(context)!,
            value,
          ),
          String value => value,
          _ => event.message.toString(),
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.success),
        );
      case ShowErrorMessage():
        final message = event.failure != null
            ? mapAppFailureToMessage(
                event.failure!,
                AppLocalizations.of(context)!,
              )
            : event.message ?? '';
        if (message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: AppColors.error),
          );
        }
      case ShowFailure():
        final message = mapAppFailureToMessage(
          event.failure,
          AppLocalizations.of(context)!,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
      case ShowFailureMessage():
        final message = mapAppFailureToMessage(
          event.failure,
          AppLocalizations.of(context)!,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
      case NavigateTo():
        final navigator = Navigator.of(context);
        if (event.isReplacement) {
          navigator.pushReplacementNamed(
            event.routeName,
            arguments: event.arguments,
          );
        } else {
          navigator.pushNamed(event.routeName, arguments: event.arguments);
        }
      case PopRoute():
        Navigator.of(context).pop(event.result);
      default:
        widget.onCustomEvent?.call(context, event);
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
  Widget build(BuildContext context) => widget.child;
}
