
import '../../model/request/login_request/login_request.dart';
import '../../model/response/login_response/login_response.dart';
import '../../../../../config/base/base_response.dart';
import '../../model/request/forget_request/forgot_password_request_dto.dart';
import '../../model/request/forget_request/reset_password_request_dto.dart';
import '../../model/request/forget_request/verify_otp_request.dart';
import '../../model/response/forget_response/forgot_password_response_dto.dart';
import '../../model/response/forget_response/reset_password_response_dto.dart';
import '../../model/response/forget_response/verify_otp_response.dart';

abstract interface class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest login);

  Future<BaseResponse<ForgotPasswordResponseDto>> forgotPassword(
      ForgotPasswordRequestDto request,
      );
  Future<BaseResponse<VerifyOtpResponse>> verifyOtp({
    required VerifyOtpRequest verifyOtpRequest,
  });
  Future<BaseResponse<ResetPasswordResponseDto>> resetPassword(
      ResetPasswordRequestDto request,
      );
}