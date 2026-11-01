sealed class ForgetPasswordAbstractEvent {}

class VerifyOtpEvent extends ForgetPasswordAbstractEvent {
  final String email;
  final String otpCode;
  VerifyOtpEvent({required this.otpCode, required this.email});
}

class ResendOtpEvent extends ForgetPasswordAbstractEvent {
  final String email;
  ResendOtpEvent({required this.email});
}

class ForgetPasswordEvent extends ForgetPasswordAbstractEvent {
  final String email;
  ForgetPasswordEvent({required this.email});
}

class ResetPasswordEvent extends ForgetPasswordAbstractEvent {
  final String newPassword;
  final String resetCode;
  final String email;
  ResetPasswordEvent({
    required this.email,
    required this.newPassword,
    required this.resetCode,
  });
}
