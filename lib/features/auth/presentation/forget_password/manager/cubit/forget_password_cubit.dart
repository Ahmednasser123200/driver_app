import 'dart:async';

import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/forget_password_entity.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/verify_oto_entity.dart';
import 'package:driver_app/features/auth/domain/use_case/forget_password_use_case.dart';
import 'package:driver_app/features/auth/domain/use_case/reset_password_use_case.dart';
import 'package:driver_app/features/auth/domain/use_case/verify_otp_use_case.dart';
import 'package:injectable/injectable.dart';

import 'forget_password_event.dart';
import 'forget_password_state.dart';

@injectable
class ForgetPasswordCubit extends BaseCubit<ForgetPasswordState, BaseUiEvent> {
  ForgetPasswordCubit(
    this._forgetPasswordUserCase,
    this._verifyOtpUserCase,
    this._resetPasswordUserCase,
  ) : super(const ForgetPasswordState());

  final ForgetPasswordUserCase _forgetPasswordUserCase;
  final VerifyOtpUseCase _verifyOtpUserCase;
  final ResetPasswordUserCase _resetPasswordUserCase;

  Timer? _resendTimer;

  void _restartOtpSession() {
    _resendTimer?.cancel();
    _resendTimer = null;
    _beginCooldown();
  }

  void _beginCooldown() {
    _resendTimer?.cancel();
    var remaining = OtpPolicy.resendCooldownSeconds;
    emit(state.copyWith(resendSecondsRemaining: remaining));
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      if (remaining <= 0) {
        timer.cancel();
        _resendTimer = null;
        emit(state.copyWith(resendSecondsRemaining: 0));
        return;
      }
      emit(state.copyWith(resendSecondsRemaining: remaining));
    });
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    _resendTimer = null;
    return super.close();
  }

  Future<void> doEvent(ForgetPasswordAbstractEvent event) async {
    switch (event) {
      case ForgetPasswordEvent():
        await _forgetPassword(email: event.email);
        break;
      case ResendOtpEvent():
        await _resendOtp(email: event.email);
        break;
      case VerifyOtpEvent():
        await _verifyOtp(email: event.email, otp: event.otpCode);
        break;
      case ResetPasswordEvent():
        await _resetPassword(
          email: event.email,
          otp: event.resetCode,
          password: event.newPassword,
        );
        break;
    }
  }

  Future<void> _forgetPassword({required String email}) async {
    emit(
      state.copyWith(
        email: email,
        forgotState: state.forgotState.copyWith(
          isLoading: true,
          errorMessage: '',
          failure: null,
        ),
      ),
    );

    final response = await _forgetPasswordUserCase(email: email);

    switch (response) {
      case Success(:final data):
        if (data case final ForgetPasswordEntity entity) {
          emit(
            state.copyWith(
              forgotState: state.forgotState.copyWith(
                isLoading: false,
                data: entity,
                errorMessage: '',
                failure: null,
              ),
            ),
          );
          emitEvent(ShowSuccessMessage(entity.message));
          emitEvent(const ForgetPasswordGoToVerification());
          _restartOtpSession();
          break;
        }

      case Error(:final failure):
        _failForgot(failure);
        break;
    }
  }

  Future<void> _resendOtp({required String email}) async {
    emit(
      state.copyWith(
        email: email,
        resendOtpState: state.resendOtpState.copyWith(
          isLoading: true,
          errorMessage: '',
          failure: null,
        ),
      ),
    );

    final response = await _forgetPasswordUserCase(email: email);

    switch (response) {
      case Success(:final data):
        if (data case final ForgetPasswordEntity entity) {
          emit(
            state.copyWith(
              resendOtpState: state.resendOtpState.copyWith(
                isLoading: false,
                data: entity,
                errorMessage: '',
                failure: null,
              ),
            ),
          );
          emitEvent(ShowSuccessMessage(entity.message));
          _restartOtpSession();
          break;
        }
      case Error(:final failure):
        _failResendOtp(failure);
        break;
    }
  }

  Future<void> _verifyOtp({required String email, required String otp}) async {
    emit(
      state.copyWith(
        otpState: state.otpState.copyWith(
          isLoading: true,
          errorMessage: '',
          failure: null,
        ),
      ),
    );

    final response = await _verifyOtpUserCase(email: email, otp: otp);

    switch (response) {
      case Success(:final data):
        if (data case final VerifyOtpEntity entity) {
          emit(
            state.copyWith(
              otpState: state.otpState.copyWith(
                isLoading: false,
                data: entity,
                errorMessage: '',
                failure: null,
              ),
            ),
          );
          emitEvent(const ForgetPasswordGoToReset());
          break;
        }
      case Error(:final failure):
        _failOtp(failure);
        break;
    }
  }

  Future<void> _resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    emit(
      state.copyWith(
        resetState: state.resetState.copyWith(
          isLoading: true,
          errorMessage: '',
          failure: null,
        ),
      ),
    );

    final response = await _resetPasswordUserCase(
      email: email,
      otp: otp,
      password: password,
    );

    switch (response) {
      case Success(:final data):
        emit(
          state.copyWith(
            resetState: state.resetState.copyWith(
              isLoading: false,
              data: data,
              errorMessage: '',
              failure: null,
            ),
          ),
        );
        emitEvent(ShowSuccessMessage(data.message));
        emitEvent(const NavigateTo(Routes.login));
        break;
      case Error(:final failure):
        _failReset(failure);
        break;
    }
  }

  void _failForgot([AppFailure? failure]) {
    final resolved = failure ?? const UnknownFailure();
    emit(
      state.copyWith(
        forgotState: state.forgotState.copyWith(
          isLoading: false,
          data: null,
          errorMessage: '',
          failure: resolved,
        ),
      ),
    );
    _reportFailure(resolved);
  }

  void _failResendOtp([AppFailure? failure]) {
    final resolved = failure ?? const UnknownFailure();
    emit(
      state.copyWith(
        resendOtpState: state.resendOtpState.copyWith(
          isLoading: false,
          data: null,
          errorMessage: '',
          failure: resolved,
        ),
      ),
    );
    _reportFailure(resolved);
  }

  void _failOtp([AppFailure? failure]) {
    final resolved = failure ?? const UnknownFailure();
    emitEvent(const ClearOtpField());
    emit(
      state.copyWith(
        otpState: state.otpState.copyWith(
          isLoading: false,
          data: null,
          errorMessage: '',
          failure: resolved,
        ),
      ),
    );
    _reportFailure(resolved);
  }

  void _failReset([AppFailure? failure]) {
    final resolved = failure ?? const UnknownFailure();
    emit(
      state.copyWith(
        resetState: state.resetState.copyWith(
          isLoading: false,
          data: null,
          errorMessage: '',
          failure: resolved,
        ),
      ),
    );
    _reportFailure(resolved);
  }

  void _reportFailure(AppFailure failure) {
    emitEvent(ShowErrorMessage(failure: failure));
  }
}
