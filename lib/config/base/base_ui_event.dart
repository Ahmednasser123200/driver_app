
import 'package:driver_app/config/errors/app_failure.dart';

part '../../features/order_details/presentation/manager/cubit/order_details_ui_event.dart';

sealed class BaseUiEvent {
  const BaseUiEvent();
}

class ShowSuccessMessage extends BaseUiEvent {
  final String message;

  const ShowSuccessMessage(this.message);
}

class ShowErrorMessage extends BaseUiEvent {
  final String message;

  const ShowErrorMessage(this.message);
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

class ShowFailureMessage extends BaseUiEvent {
  final AppFailure failure;

  const ShowFailureMessage(this.failure);
}
