import 'package:driver_app/l10n/generated/app_localizations.dart';

enum AppSuccessEnum { orderAccepted }

String handleSuccessText(AppLocalizations local, AppSuccessEnum message) {
  switch (message) {
    case AppSuccessEnum.orderAccepted:
      return local.accepted;
  }
}
