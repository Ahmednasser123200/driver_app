import 'dart:async';

import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/config/localization/app_failure_message_mapper.dart';
import 'package:driver_app/config/localization/validation_error_message_mapper.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/config/utils/auth_validators.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/forget_password_entity.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/verify_oto_entity.dart';
import 'package:driver_app/features/auth/domain/use_case/forget_password_user_case.dart';
import 'package:driver_app/features/auth/domain/use_case/reset_password_user_case.dart';
import 'package:driver_app/features/auth/domain/use_case/verify_otp_user_case.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';
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
  final VerifyOtpUserCase _verifyOtpUserCase;
  final ResetPasswordUserCase _resetPasswordUserCase;

  Future<AppLocalizations>? _l10nFuture;
  Timer? _resendTimer;

  void startResendCooldown() {
    if (_resendTimer?.isActive ?? false) return;
    _beginCooldown(verifyAttemptsRemaining: state.verifyAttemptsRemaining);
  }

  void _restartOtpSession() {
    _resendTimer?.cancel();
    _resendTimer = null;
    _beginCooldown(verifyAttemptsRemaining: OtpPolicy.maxVerifyAttempts);
  }

  void _beginCooldown({required int verifyAttemptsRemaining}) {
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.resendSecondsRemaining - 1;
      if (next <= 0) {
        timer.cancel();
        _resendTimer = null;
        emit(state.copyWith(resendSecondsRemaining: 0));
        return;
      }
      emit(state.copyWith(resendSecondsRemaining: next));
    });
    emit(
      state.copyWith(
        resendSecondsRemaining: OtpPolicy.resendCooldownSeconds,
        verifyAttemptsRemaining: verifyAttemptsRemaining,
      ),
    );
  }

  void _consumeVerifyAttempt() {
    if (state.isOtpLockedOut) return;
    emit(
      state.copyWith(
        verifyAttemptsRemaining: state.verifyAttemptsRemaining - 1,
      ),
    );
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    _resendTimer = null;
    return super.close();
  }

  Future<void> doEvent(ForgetPasswordEvent event) async {
    switch (event) {
      case ForgetBassEvent():
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
    final l10n = await _localizations();

    final validationError = AuthValidators.email(email);
    if (validationError != null) {
      final message = mapValidationErrorToMessage(validationError, l10n);
      emit(
        state.copyWith(
          forgotstate: state.forgotstate.copyWith(
            data: null,
            errorMessage: message,
          ),
        ),
      );
      _reportError(message);
      return;
    }

    emit(
      state.copyWith(
        forgotstate: state.forgotstate.copyWith(
          isLoading: true,
          errorMessage: '',
        ),
      ),
    );

    final response = await _forgetPasswordUserCase(email: email);

    switch (response) {
      case Success(:final data):
        if (data case final ForgetPasswordEntity entity) {
          emit(
            state.copyWith(
              forgotstate: state.forgotstate.copyWith(
                isLoading: false,
                data: entity,
                errorMessage: '',
              ),
            ),
          );
          emitEvent(ShowSuccessMessage(entity.message));
          emitEvent(
            NavigateTo(Routes.verificationCode, arguments: {'email': email}),
          );
          break;
        }
        _failForgot(l10n);
        break;
      case Error(:final failure):
        _failForgot(l10n, failure);
        break;
    }
  }

  Future<void> _resendOtp({required String email}) async {
    final l10n = await _localizations();

    final validationError = AuthValidators.email(email);
    if (validationError != null) {
      final message = mapValidationErrorToMessage(validationError, l10n);
      emit(
        state.copyWith(
          resendOtpState: state.resendOtpState.copyWith(
            data: null,
            errorMessage: message,
          ),
        ),
      );
      _reportError(message);
      return;
    }

    emit(
      state.copyWith(
        resendOtpState: state.resendOtpState.copyWith(
          isLoading: true,
          errorMessage: '',
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
              ),
            ),
          );
          emitEvent(ShowSuccessMessage(entity.message));
          _restartOtpSession();
          break;
        }
        _failResendOtp(l10n);
        break;
      case Error(:final failure):
        _failResendOtp(l10n, failure);
        break;
    }
  }

  Future<void> _verifyOtp({required String email, required String otp}) async {
    final l10n = await _localizations();

    if (state.isOtpLockedOut) {
      emitEvent(ShowErrorMessage(l10n.otpMaxAttemptsReached));
      return;
    }

    final emailError = AuthValidators.email(email);
    final otpError = otp.trim().isEmpty ? ValidationError.fieldRequired : null;
    final validationError = emailError ?? otpError;
    if (validationError != null) {
      final message = mapValidationErrorToMessage(validationError, l10n);
      emit(
        state.copyWith(
          otpState: state.otpState.copyWith(data: null, errorMessage: message),
        ),
      );
      _reportError(message);
      return;
    }

    emit(
      state.copyWith(
        otpState: state.otpState.copyWith(isLoading: true, errorMessage: ''),
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
              ),
            ),
          );
          emitEvent(
            NavigateTo(
              Routes.resetPassword,
              arguments: {'email': email, 'otpcode': entity.resetToken},
            ),
          );
          break;
        }
        _failOtp(l10n);
        break;
      case Error(:final failure):
        _failOtp(l10n, failure);
        break;
    }
  }

  Future<void> _resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    final l10n = await _localizations();

    if (otp.trim().isEmpty) {
      final message = mapValidationErrorToMessage(
        ValidationError.fieldRequired,
        l10n,
      );
      emit(
        state.copyWith(
          resetstate: state.resetstate.copyWith(
            data: null,
            errorMessage: message,
          ),
        ),
      );
      _reportError(message);
      return;
    }

    emit(
      state.copyWith(
        resetstate: state.resetstate.copyWith(
          isLoading: true,
          errorMessage: '',
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
            resetstate: state.resetstate.copyWith(
              isLoading: false,
              data: data,
              errorMessage: '',
            ),
          ),
        );
        emitEvent(ShowSuccessMessage(data.message));
        emitEvent(const NavigateTo(Routes.login));
        break;
      case Error(:final failure):
        _failReset(l10n, failure);
        break;
    }
  }

  void _failForgot(AppLocalizations l10n, [AppFailure? failure]) {
    final message = _messageFor(l10n, failure);
    emit(
      state.copyWith(
        forgotstate: state.forgotstate.copyWith(
          isLoading: false,
          data: null,
          errorMessage: message,
        ),
      ),
    );
    _reportError(message);
  }

  void _failResendOtp(AppLocalizations l10n, [AppFailure? failure]) {
    final message = _messageFor(l10n, failure);
    emit(
      state.copyWith(
        resendOtpState: state.resendOtpState.copyWith(
          isLoading: false,
          data: null,
          errorMessage: message,
        ),
      ),
    );
    _reportError(message);
  }

  void _failOtp(AppLocalizations l10n, [AppFailure? failure]) {
    final message = _messageFor(l10n, failure);
    _consumeVerifyAttempt();
    emit(
      state.copyWith(
        otpState: state.otpState.copyWith(
          isLoading: false,
          data: null,
          errorMessage: message,
        ),
      ),
    );
    _reportError(message);
  }

  void _failReset(AppLocalizations l10n, [AppFailure? failure]) {
    final message = _messageFor(l10n, failure);
    emit(
      state.copyWith(
        resetstate: state.resetstate.copyWith(
          isLoading: false,
          data: null,
          errorMessage: message,
        ),
      ),
    );
    _reportError(message);
  }

  String _messageFor(AppLocalizations l10n, AppFailure? failure) {
    return mapAppFailureToMessage(failure ?? const UnknownFailure(), l10n);
  }

  void _reportError(String? message) {
    if (message == null || message.isEmpty) return;
    emitEvent(ShowErrorMessage(message));
  }

  Future<AppLocalizations> _localizations() {
    return _l10nFuture ??= _loadLocalizations();
  }

  Future<AppLocalizations> _loadLocalizations() async {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    try {
      return await AppLocalizations.delegate.load(locale);
    } catch (_) {
      return AppLocalizations.delegate.load(const Locale('en'));
    }
  }
}
