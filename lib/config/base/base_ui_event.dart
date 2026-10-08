import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/config/localization/handle_success_text.dart';

sealed class BaseUiEvent {
  const BaseUiEvent();
}



final class ShowSuccessMessage extends BaseUiEvent {
  final AppMessage message;
  const ShowSuccessMessage(this.message);
}

final class ShowFailureMessage extends BaseUiEvent {
  final AppFailure failure;
  const ShowFailureMessage(this.failure);
}

class NavigateTo extends BaseUiEvent {
  final String routeName;
  final Object? arguments;
  const NavigateTo(this.routeName, {this.arguments});
}

class PopRoute extends BaseUiEvent {
  final Object? result;
  const PopRoute([this.result]);
}
