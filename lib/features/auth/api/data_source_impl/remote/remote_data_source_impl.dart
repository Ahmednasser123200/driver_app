import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/base/base_response.dart';
import '../../../../../config/dio/dio_failure_mapper.dart';
import '../../../../../config/errors/app_failure.dart';
import '../../../data/data_source/remote_data_source/remote_data_source.dart';
import '../../../data/model/request/forget_request/forgot_password_request_dto.dart';
import '../../../data/model/request/forget_request/reset_password_request_dto.dart';
import '../../../data/model/request/forget_request/verify_otp_request.dart';
import '../../../data/model/response/forget_response/forgot_password_response_dto.dart';
import '../../../data/model/response/forget_response/reset_password_response_dto.dart';
import '../../../data/model/response/forget_response/verify_otp_response.dart';
import '../../client/auth_api_client.dart';

@Injectable(as: RemoteDataSource)
class RemoteDataSourceImpl implements RemoteDataSource {
  final AuthApiClient _authApiClient;

  RemoteDataSourceImpl(this._authApiClient);

  @override
  Future<BaseResponse<ForgotPasswordResponseDto>> forgotPassword(
    ForgotPasswordRequestDto request,
  ) async {
    try {
      final response = await _authApiClient.forgotPassword(request);
      if (response.isSuccess) {
        return Success(response);
      }
      return Error(_applicationLevelFailure(response.message));
    } on DioException catch (error) {
      return Error(mapDioExceptionToAppFailure(error));
    } catch (_) {
      return Error(const UnknownFailure());
    }
  }

  @override
  Future<BaseResponse<VerifyOtpResponse>> verifyOtp({
    required VerifyOtpRequest verifyOtpRequest,
  }) async {
    try {
      final response = await _authApiClient.verifyOtp(verifyOtpRequest);
      if (response.isSuccess != true) {
        return Error(_applicationLevelFailure(response.message));
      }
      if (response.data?.resetToken == null) {
        return Error(const ServerFailure());
      }
      return Success(response);
    } on DioException catch (error) {
      return Error(mapDioExceptionToAppFailure(error));
    } catch (_) {
      return Error(const UnknownFailure());
    }
  }

  @override
  Future<BaseResponse<ResetPasswordResponseDto>> resetPassword(
    ResetPasswordRequestDto request,
  ) async {
    try {
      final response = await _authApiClient.resetPassword(request);
      if (response.isSuccess) {
        return Success(response);
      }
      return Error(_applicationLevelFailure(response.message));
    } on DioException catch (error) {
      return Error(mapDioExceptionToAppFailure(error));
    } catch (_) {
      return Error(const UnknownFailure());
    }
  }

  AppFailure _applicationLevelFailure(String? message) {
    final trimmed = message?.trim();
    return BadRequestFailure(
      serverMessage: trimmed == null || trimmed.isEmpty ? null : trimmed,
    );
  }
}
