import 'package:driver_app/config/base/base_state.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/entities/forget_entity/forget_password_entity.dart';
import '../../../../domain/entities/forget_entity/reset_passsword_entity.dart';
import '../../../../domain/entities/forget_entity/verify_oto_entity.dart';

abstract final class OtpPolicy {
  static const int resendCooldownSeconds = 30;
  static const int maxVerifyAttempts = 5;
}

class ForgetPasswordState extends Equatable {
  final BaseState<VerifyOtpEntity> otpState;
  final BaseState<ForgetPasswordEntity> resendOtpState;
  final BaseState<ForgetPasswordEntity> forgotstate;
  final BaseState<ResetPassswordEntity> resetstate;
  final int resendSecondsRemaining;
  final int verifyAttemptsRemaining;

  const ForgetPasswordState({
    this.forgotstate = const BaseState<ForgetPasswordEntity>(),
    this.resetstate = const BaseState<ResetPassswordEntity>(),
    this.otpState = const BaseState<VerifyOtpEntity>(),
    this.resendOtpState = const BaseState<ForgetPasswordEntity>(),
    this.resendSecondsRemaining = 0,
    this.verifyAttemptsRemaining = OtpPolicy.maxVerifyAttempts,
  });

  bool get isOtpLockedOut => verifyAttemptsRemaining <= 0;
  bool get canResendOtp => resendSecondsRemaining <= 0;

  ForgetPasswordState copyWith({
    BaseState<VerifyOtpEntity>? otpState,
    BaseState<ForgetPasswordEntity>? resendOtpState,
    BaseState<ForgetPasswordEntity>? forgotstate,
    BaseState<ResetPassswordEntity>? resetstate,
    int? resendSecondsRemaining,
    int? verifyAttemptsRemaining,
  }) {
    return ForgetPasswordState(
      forgotstate: forgotstate ?? this.forgotstate,
      resetstate: resetstate ?? this.resetstate,
      otpState: otpState ?? this.otpState,
      resendOtpState: resendOtpState ?? this.resendOtpState,
      resendSecondsRemaining:
          resendSecondsRemaining ?? this.resendSecondsRemaining,
      verifyAttemptsRemaining:
          verifyAttemptsRemaining ?? this.verifyAttemptsRemaining,
    );
  }

  @override
  List<Object?> get props => [
    otpState,
    resendOtpState,
    forgotstate,
    resetstate,
    resendSecondsRemaining,
    verifyAttemptsRemaining,
  ];
}
