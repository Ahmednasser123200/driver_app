import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

abstract class LocaleProvider {
  Locale get locale;
}

@Injectable(as: LocaleProvider)
class LocaleProviderImpl implements LocaleProvider {
  @override
  Locale get locale => WidgetsBinding.instance.platformDispatcher.locale;
}
