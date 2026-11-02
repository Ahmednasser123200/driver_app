import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/localization/app_failure_message_mapper.dart';
import 'package:driver_app/config/localization/handle_success_text.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

mixin HandleEventUi {
  void handleEvent(BuildContext context, BaseUiEvent event) {
    final local = AppLocalizations.of(context)!;
    switch (event) {
      case ShowSuccessMessage():
        final message = switch (event.message) {
          AppSuccessEnum value => handleSuccessText(local, value),
          String value => value,
          _ => event.message.toString(),
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
        break;
      case ShowFailureMessage():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mapAppFailureToMessage(event.failure, local)),
            backgroundColor: Colors.red,
          ),
        );
        break;
      case PopRoute():
        Navigator.of(context).pop(event.result);
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
    }
  }
}
