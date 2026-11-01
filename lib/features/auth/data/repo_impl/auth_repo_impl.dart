import 'package:dio/dio.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/dio/dio_failure_mapper.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart';
import 'package:driver_app/features/auth/data/model/request/login_request/login_request.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/country_entity.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/vehicle_type_entity.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_credentials.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_entity.dart';
import 'package:driver_app/features/auth/domain/repo/auth_repo.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/token_storage_service.dart';
import '../../domain/entities/apply_entity/applications_entity.dart';
import '../../domain/entities/forget_entity/forget_password_entity.dart';
import '../../domain/entities/forget_entity/reset_passsword_entity.dart';
import '../../domain/entities/forget_entity/verify_oto_entity.dart';
import '../model/request/apply_request/application_request_dto.dart';
import '../model/request/forget_request/forgot_password_request_dto.dart';
import '../model/request/forget_request/reset_password_request_dto.dart';
import '../model/request/forget_request/verify_otp_request.dart';
import '../model/response/apply_response/application_response_dto.dart';
import '../model/response/apply_response/country_dto.dart';
import '../model/response/apply_response/vehicle_type_dto.dart';

@Injectable(as: AuthRepo)
class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorageService _tokenStorage;

  AuthRepoImpl(this._remoteDataSource, this._tokenStorage);

  @override
  Future<BaseResponse<LoginEntity>> login(
    LoginCredentials credentials, {
    bool rememberMe = false,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        LoginRequest(
          email: credentials.email,
          password: credentials.password,
          deviceId: '',
          fcmToken: '',
        ),
      );

      final loginData = response.data;
      if (response.isSuccess == true && loginData != null) {
        final entity = loginData.toLoginEntity();

        final role = entity.user?.role.toLowerCase();
        if (role != 'driver') {
          return Error(NotDriverAccountFailure());
        }

        await _tokenStorage.saveAccessToken(
          entity.accessToken,
          persist: rememberMe,
        );
        await _tokenStorage.saveRefreshToken(
          entity.refreshToken,
          persist: rememberMe,
        );

        if (rememberMe) {
          await _tokenStorage.saveRememberedEmail(credentials.email);
        } else {
          await _tokenStorage.deleteRememberedEmail();
        }

        return Success(entity);
      }

      return Error(BadResponse());
    } on DioException catch (e) {
      return Error(mapDioExceptionToAppFailure(e));
    } catch (e) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<BaseResponse<ForgetPasswordEntity>> forgetPassword(
    String email,
  ) async {
    final response = await _remoteDataSource.forgotPassword(
      ForgotPasswordRequestDto(email: email),
    );
    return switch (response) {
      Success(:final data) => Success(data.toDomain()),
      Error(:final failure) => Error(failure),
    };
  }

  @override
  Future<BaseResponse<ResetPasswordEntity>> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    final response = await _remoteDataSource.resetPassword(
      ResetPasswordRequestDto(
        resetToken: otp,
        newPassword: password,
        confirmPassword: password,
      ),
    );
    return switch (response) {
      Success(:final data) => Success(data.toDomain()),
      Error(:final failure) => Error(failure),
    };
  }

  @override
  Future<BaseResponse<VerifyOtpEntity>> verifyOtp(
    String email,
    String otp,
  ) async {
    final response = await _remoteDataSource.verifyOtp(
      verifyOtpRequest: VerifyOtpRequest(email: email, otp: otp),
    );
    return switch (response) {
      Success(:final data) when data.data != null => Success(
        data.data!.toEntity(),
      ),
      Success() => Error(const ServerFailure()),
      Error(:final failure) => Error(failure),
    };
  }

  @override
  Future<void> saveRememberedEmail(String email) =>
      _tokenStorage.saveRememberedEmail(email);
  @override
  Future<void> deleteRememberedEmail() => _tokenStorage.deleteRememberedEmail();

  @override
  Future<String?> loadRememberedEmail() => _tokenStorage.getRememberedEmail();

  @override
  Future<BaseResponse<void>> addApplication(
    ApplicationEntity application,
  ) async {
    final response = await _remoteDataSource.addApplication(
      ApplicationRequestDto.fromEntity(application),
    );

    switch (response) {
      case Success<ApplicationResponseDto>():
        return const Success<void>(null);
      case Error<ApplicationResponseDto>():
        return Error<void>(response.failure);
    }
  }

  @override
  Future<BaseResponse<List<CountryEntity>>> getCountries() async {
    final response = await _remoteDataSource.getCountries();
    switch (response) {
      case Success<List<CountryDto>>(:final data):
        return Success(data.map((e) => e.toEntity()).toList());
      case Error<List<CountryDto>>(:final failure):
        return Error(failure);
    }
  }

  @override
  Future<BaseResponse<List<VehicleTypeEntity>>> getVehicleTypes() async {
    final response = await _remoteDataSource.getVehicleTypes();
    switch (response) {
      case Success<List<VehicleTypeDto>>(:final data):
        return Success(data.map((e) => e.toEntity()).toList());
      case Error<List<VehicleTypeDto>>(:final failure):
        return Error(failure);
    }
  }
}
