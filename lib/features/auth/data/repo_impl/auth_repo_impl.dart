import 'package:dio/dio.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/dio/dio_failure_mapper.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/auth/api/service/secure_storage.dart';
import 'package:driver_app/features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart';
import 'package:driver_app/features/auth/data/model/request/login_request/login_request.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_credentials.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_entity.dart';
import 'package:driver_app/features/auth/domain/repo/auth_repo.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: AuthRepo)
class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  AuthRepoImpl(this._remoteDataSource, this._secureStorage);

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

        await _secureStorage.saveAccessToken(
          entity.accessToken,
          rememberMe: rememberMe,
        );
        await _secureStorage.saveRefreshToken(
          entity.refreshToken,
          rememberMe: rememberMe,
        );

        return Success(entity);
      }

      return Error(BadResponse());
    } on DioException catch (e) {
      return Error(mapDioExceptionToAppFailure(e));
    } catch (e) {
      return const Error(UnknownFailure());
    }
  }
}
