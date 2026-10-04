import 'package:driver_app/config/base/base_state.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/entities/forget_entity/forget_password_entity.dart';
import '../../../../domain/entities/forget_entity/reset_passsword_entity.dart';
import '../../../../domain/entities/forget_entity/verify_oto_entity.dart';

abstract final class OtpPolicy {
  static const int resendCooldownSeconds = 30;
}

class ForgetPasswordState extends Equatable {
  final BaseState<VerifyOtpEntity> otpState;
  final BaseState<ForgetPasswordEntity> resendOtpState;
  final BaseState<ForgetPasswordEntity> forgotState;
  final BaseState<ResetPasswordEntity> resetState;
  final int resendSecondsRemaining;
  final String email;

  const ForgetPasswordState({
    this.forgotState = const BaseState<ForgetPasswordEntity>(),
    this.resetState = const BaseState<ResetPasswordEntity>(),
    this.otpState = const BaseState<VerifyOtpEntity>(),
    this.resendOtpState = const BaseState<ForgetPasswordEntity>(),
    this.resendSecondsRemaining = 0,
    this.email = '',
  });

  bool get canResendOtp => resendSecondsRemaining <= 0;

  ForgetPasswordState copyWith({
    BaseState<VerifyOtpEntity>? otpState,
    BaseState<ForgetPasswordEntity>? resendOtpState,
    BaseState<ForgetPasswordEntity>? forgotState,
    BaseState<ResetPasswordEntity>? resetState,
    int? resendSecondsRemaining,
    String? email,
  }) {
    return ForgetPasswordState(
      forgotState: forgotState ?? this.forgotState,
      resetState: resetState ?? this.resetState,
      otpState: otpState ?? this.otpState,
      resendOtpState: resendOtpState ?? this.resendOtpState,
      resendSecondsRemaining: resendSecondsRemaining ?? this.resendSecondsRemaining,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [
    otpState,
    resendOtpState,
    forgotState,
    resetState,
    resendSecondsRemaining,
    email,
  ];
}
