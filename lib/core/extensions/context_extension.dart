import 'package:flutter/widgets.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';

extension LocalizedContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
