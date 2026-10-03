part of '../../../../../../config/base/base_ui_event.dart';

sealed class ForgetPasswordUiEvent extends BaseUiEvent {
  const ForgetPasswordUiEvent();
}

class ClearOtpField extends ForgetPasswordUiEvent {
  const ClearOtpField();
}

class ForgetPasswordGoToVerification extends ForgetPasswordUiEvent {
  const ForgetPasswordGoToVerification();
}

class ForgetPasswordGoToReset extends ForgetPasswordUiEvent {
  const ForgetPasswordGoToReset();
}
