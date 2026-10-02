import 'package:driver_app/config/base/base_ui_event.dart';

sealed class LoginUiEvent extends BaseUiEvent {
  const LoginUiEvent();
}

class EmailPreFilledEvent extends LoginUiEvent {
  final String email;
  const EmailPreFilledEvent(this.email);
}
