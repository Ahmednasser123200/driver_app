import '../../../../../config/base/base_ui_event.dart';

sealed class LoginUiEvent extends BaseUiEvent {
  const LoginUiEvent();
}

class AutofillRememberedEmailEvent extends LoginUiEvent {
  final String email;

  const AutofillRememberedEmailEvent(this.email);
}
