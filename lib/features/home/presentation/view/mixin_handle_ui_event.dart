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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(handleSuccessText(local, event.message)),
            backgroundColor: Colors.green,
          ),
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
      case NavigateTo():
        Navigator.of(
          context,
        ).pushNamed(event.routeName, arguments: event.arguments);
      case PopRoute():
        Navigator.of(context).pop(event.result);
    }
  }
}
