import 'package:injectable/injectable.dart';
import '../../../../config/base/base_response.dart';
import '../../../../config/errors/app_failure.dart';
import '../../api/service/secure_storage.dart';
import '../../domain/entities/forget_entity/forget_password_entity.dart';
import '../../domain/entities/forget_entity/reset_passsword_entity.dart';
import '../../domain/entities/forget_entity/verify_oto_entity.dart';
import '../../domain/repo/auth_repo.dart';
import '../data_source/remote_data_source/remote_data_source.dart';
import '../model/request/forget_request/forgot_password_request_dto.dart';
import '../model/request/forget_request/reset_password_request_dto.dart';
import '../model/request/forget_request/verify_otp_request.dart';

@Injectable(as: AuthRepo)
class AuthRepoImpl implements AuthRepo {
  final RemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  AuthRepoImpl(this._remoteDataSource, this._secureStorage);

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
      _secureStorage.saveRememberedEmail(email);
  @override
  Future<void> deleteRememberedEmail() =>
      _secureStorage.deleteRememberedEmail();

  @override
  Future<String?> loadRememberedEmail() => _secureStorage.getRememberedEmail();

  @override
  Future<BaseResponse<dynamic>> login(dynamic credentials) {
    throw UnimplementedError();
  }

  @override
  Future<BaseResponse<dynamic>> register(dynamic registerData) {
    throw UnimplementedError();
  }
}
