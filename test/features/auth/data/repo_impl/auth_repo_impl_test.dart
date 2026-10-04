import 'package:dio/dio.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/auth/api/service/secure_storage.dart';
import 'package:driver_app/features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart';
import 'package:driver_app/features/auth/data/model/data_dto.dart';
import 'package:driver_app/features/auth/data/model/request/login_request/login_request.dart';
import 'package:driver_app/features/auth/data/model/response/login_response/login_response.dart';
import 'package:driver_app/features/auth/data/model/user_dto.dart';
import 'package:driver_app/features/auth/data/repo_impl/auth_repo_impl.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_credentials.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockSecureStorageService extends Mock implements SecureStorageService {}
class FakeLoginRequest extends Fake implements LoginRequest {}

void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockSecureStorageService mockSecureStorage;
  late AuthRepoImpl authRepo;

  setUpAll(() {
    registerFallbackValue(FakeLoginRequest());
  });

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockSecureStorage = MockSecureStorageService();
    authRepo = AuthRepoImpl(mockRemoteDataSource, mockSecureStorage);
  });

  group('AuthRepoImpl - login', () {
    const credentials = LoginCredentials(
      email: 'driver@example.com',
      password: 'password123',
    );

    final driverUserDto = UserDto(
      id: 'd1',
      fullName: 'Driver Name',
      email: 'driver@example.com',
      role: 'driver',
      status: 'Active',
    );

    final successfulDataDto = LoginDataDto(
      accessToken: 'access_token_val',
      refreshToken: 'refresh_token_val',
      expiresIn: 3600,
      driverStatus: 'Approved',
      user: driverUserDto,
    );

    test('returns Success and saves tokens when login is successful for driver role with rememberMe=false', () async {
      // Arrange
      final response = LoginResponse(
        isSuccess: true,
        errorCode: 200,
        message: 'Success',
        data: successfulDataDto,
      );

      when(() => mockRemoteDataSource.login(any())).thenAnswer((_) async => response);
      when(() => mockSecureStorage.saveAccessToken(any(), rememberMe: any(named: 'rememberMe')))
          .thenAnswer((_) async {});
      when(() => mockSecureStorage.saveRefreshToken(any(), rememberMe: any(named: 'rememberMe')))
          .thenAnswer((_) async {});

      // Act
      final result = await authRepo.login(credentials, rememberMe: false);

      // Assert
      expect(result, isA<Success<LoginEntity>>());
      final successResult = result as Success<LoginEntity>;
      expect(successResult.data.accessToken, equals('access_token_val'));
      expect(successResult.data.user?.role, equals('driver'));

      verify(() => mockSecureStorage.saveAccessToken('access_token_val', rememberMe: false)).called(1);
      verify(() => mockSecureStorage.saveRefreshToken('refresh_token_val', rememberMe: false)).called(1);
    });

    test('returns Success and saves tokens when login is successful for driver role with rememberMe=true', () async {
      // Arrange
      final response = LoginResponse(
        isSuccess: true,
        errorCode: 200,
        message: 'Success',
        data: successfulDataDto,
      );

      when(() => mockRemoteDataSource.login(any())).thenAnswer((_) async => response);
      when(() => mockSecureStorage.saveAccessToken(any(), rememberMe: any(named: 'rememberMe')))
          .thenAnswer((_) async {});
      when(() => mockSecureStorage.saveRefreshToken(any(), rememberMe: any(named: 'rememberMe')))
          .thenAnswer((_) async {});

      // Act
      final result = await authRepo.login(credentials, rememberMe: true);

      // Assert
      expect(result, isA<Success<LoginEntity>>());
      verify(() => mockSecureStorage.saveAccessToken('access_token_val', rememberMe: true)).called(1);
      verify(() => mockSecureStorage.saveRefreshToken('refresh_token_val', rememberMe: true)).called(1);
    });

    test('returns Error with NotDriverAccountFailure when user role is not driver', () async {
      // Arrange
      final nonDriverUserDto = UserDto(
        id: 'u1',
        fullName: 'Client Name',
        email: 'client@example.com',
        role: 'customer',
        status: 'Active',
      );

      final response = LoginResponse(
        isSuccess: true,
        errorCode: 200,
        message: 'Success',
        data: LoginDataDto(
          accessToken: 'acc',
          refreshToken: 'ref',
          expiresIn: 3600,
          driverStatus: 'Approved',
          user: nonDriverUserDto,
        ),
      );

      when(() => mockRemoteDataSource.login(any())).thenAnswer((_) async => response);

      // Act
      final result = await authRepo.login(credentials);

      // Assert
      expect(result, isA<Error<LoginEntity>>());
      final errorResult = result as Error<LoginEntity>;
      expect(errorResult.failure, isA<NotDriverAccountFailure>());

      verifyNever(() => mockSecureStorage.saveAccessToken(any(), rememberMe: any(named: 'rememberMe')));
      verifyNever(() => mockSecureStorage.saveRefreshToken(any(), rememberMe: any(named: 'rememberMe')));
    });

    test('returns Error with BadResponse when response.isSuccess is false or data is null', () async {
      // Arrange
      final response = LoginResponse(
        isSuccess: false,
        errorCode: 400,
        message: 'Invalid credentials',
        data: null,
      );

      when(() => mockRemoteDataSource.login(any())).thenAnswer((_) async => response);

      // Act
      final result = await authRepo.login(credentials);

      // Assert
      expect(result, isA<Error<LoginEntity>>());
      final errorResult = result as Error<LoginEntity>;
      expect(errorResult.failure, isA<BadResponse>());
    });

    test('returns Error with mapped failure when DioException occurs', () async {
      // Arrange
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        type: DioExceptionType.connectionTimeout,
      );

      when(() => mockRemoteDataSource.login(any())).thenThrow(dioException);

      // Act
      final result = await authRepo.login(credentials);

      // Assert
      expect(result, isA<Error<LoginEntity>>());
      final errorResult = result as Error<LoginEntity>;
      expect(errorResult.failure, isA<TimeoutFailure>());
    });

    test('returns UnknownFailure when a generic Exception occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.login(any())).thenThrow(Exception('Unknown'));

      // Act
      final result = await authRepo.login(credentials);

      // Assert
      expect(result, isA<Error<LoginEntity>>());
      final errorResult = result as Error<LoginEntity>;
      expect(errorResult.failure, isA<UnknownFailure>());
    });
  });
}
