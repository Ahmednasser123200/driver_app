import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/auth/data/model/verify_otp_data_dto.dart';
import 'package:driver_app/features/auth/data/model/response/forget_response/forgot_password_response_dto.dart';
import 'package:driver_app/features/auth/data/model/response/forget_response/reset_password_response_dto.dart';
import 'package:driver_app/features/auth/data/model/response/forget_response/verify_otp_response.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/forget_password_entity.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/reset_passsword_entity.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/verify_oto_entity.dart';
import 'package:mockito/mockito.dart';

/// mockito can synthesise dummies for primitives but not for the generic
/// [BaseResponse] wrapper or for the auth DTOs, whose constructors are
/// non-const or require non-nullable fields.
///
/// Every type that shows up as the *return value* of a stubbed call must be
/// registered once, before the first `when(...)`, otherwise mockito throws
/// `MissingDummyValueError` while capturing the call.
void registerAuthDummies() {
  // The forget-password / verify-otp use cases are declared with a dynamic
  // payload, so mockito needs the untyped wrapper to capture their stubs.
  provideDummy<BaseResponse<dynamic>>(Error<dynamic>(const NotFoundFailure()));

  provideDummy<BaseResponse<ForgetPasswordEntity>>(
    Error<ForgetPasswordEntity>(const NotFoundFailure()),
  );
  provideDummy<BaseResponse<VerifyOtpEntity>>(
    Error<VerifyOtpEntity>(const NotFoundFailure()),
  );
  provideDummy<BaseResponse<ResetPasswordEntity>>(
    Error<ResetPasswordEntity>(const NotFoundFailure()),
  );

  provideDummy<ForgotPasswordResponseDto>(
    ForgotPasswordResponseDto(
      data: '',
      message: '',
      errorCode: '0',
      isSuccess: false,
    ),
  );
  provideDummy<VerifyOtpResponse>(
    VerifyOtpResponse(isSuccess: false, errorCode: 400, message: ''),
  );
  provideDummy<ResetPasswordResponseDto>(
    ResetPasswordResponseDto(
      data: '',
      message: '',
      errorCode: '0',
      isSuccess: false,
    ),
  );
  provideDummy<VerifyOtpDataDto>(VerifyOtpDataDto());

  // The remote data source returns the generic wrapper around the raw DTOs.
  provideDummy<BaseResponse<ForgotPasswordResponseDto>>(
    Error<ForgotPasswordResponseDto>(const NotFoundFailure()),
  );
  provideDummy<BaseResponse<VerifyOtpResponse>>(
    Error<VerifyOtpResponse>(const NotFoundFailure()),
  );
  provideDummy<BaseResponse<ResetPasswordResponseDto>>(
    Error<ResetPasswordResponseDto>(const NotFoundFailure()),
  );
}
