import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/base/base_response.dart';
import '../../../../../config/base/execute_api.dart';
import '../../../../../config/dio/dio_failure_mapper.dart';
import '../../../../../config/errors/app_failure.dart';
import '../../../data/data_source/remote_data_source/auth_remote_data_source.dart';
import '../../../data/model/request/apply_request/application_request_dto.dart';
import '../../../data/model/request/forget_request/forgot_password_request_dto.dart';
import '../../../data/model/request/forget_request/reset_password_request_dto.dart';
import '../../../data/model/request/forget_request/verify_otp_request.dart';
import '../../../data/model/request/login_request/login_request.dart';
import '../../../data/model/response/apply_response/application_response_dto.dart';
import '../../../data/model/response/apply_response/country_dto.dart';
import '../../../data/model/response/apply_response/vehicle_type_dto.dart';
import '../../../data/model/response/forget_response/forgot_password_response_dto.dart';
import '../../../data/model/response/forget_response/reset_password_response_dto.dart';
import '../../../data/model/response/forget_response/verify_otp_response.dart';
import '../../../data/model/response/login_response/login_response.dart';
import '../../client/auth_api_client.dart';
import '../../client/auth_client.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthClient _client;
  final AuthApiClient _authApiClient;

  AuthRemoteDataSourceImpl(this._client, this._authApiClient);

  @override
  Future<LoginResponse> login(LoginRequest login) async {
    return await _authApiClient.login(login);
  }

  @override
  Future<BaseResponse<ForgotPasswordResponseDto>> forgotPassword(
    ForgotPasswordRequestDto request,
  ) async {
    try {
      final response = await _authApiClient.forgotPassword(request);
      if (response.isSuccess) {
        return Success(response);
      }
      return Error(
        ServerFailure(serverMessage: _trimMessage(response.message)),
      );
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
        return Error(
          UnauthorizedFailure(serverMessage: _trimMessage(response.message)),
        );
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
      return Error(
        UnauthorizedFailure(serverMessage: _trimMessage(response.message)),
      );
    } on DioException catch (error) {
      return Error(mapDioExceptionToAppFailure(error));
    } catch (_) {
      return Error(const UnknownFailure());
    }
  }

  @override
  Future<BaseResponse<ApplicationResponseDto>> addApplication(
    ApplicationRequestDto request,
  ) {
    return executeApi(() => _client.addApplication(request.toFormData()));
  }

  @override
  Future<BaseResponse<List<CountryDto>>> getCountries() {
    return executeApi(() => _client.getCountries());
  }

  @override
  Future<BaseResponse<List<VehicleTypeDto>>> getVehicleTypes() {
    return executeApi(() async {
      final response = await _client.getVehicleTypes();
      return response.data ?? [];
    });
  }

  String? _trimMessage(String? message) {
    final trimmed = message?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
