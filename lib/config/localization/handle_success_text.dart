import 'package:driver_app/l10n/generated/app_localizations.dart';

enum AppMessage { orderAccepted }


  String handleSuccessText(AppLocalizations local, AppMessage message) {
  switch (message) {
    case AppMessage.orderAccepted:
      return local.accepted;
  }
}