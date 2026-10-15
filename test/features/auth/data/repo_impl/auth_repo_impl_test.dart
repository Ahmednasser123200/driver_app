import 'package:driver_app/core/services/token_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart';
import 'package:driver_app/features/auth/data/model/request/apply_request/application_request_dto.dart';
import 'package:driver_app/features/auth/data/model/response/apply_response/application_response_dto.dart';
import 'package:driver_app/features/auth/data/repo_impl/auth_repo_impl.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/applications_entity.dart';

import 'package:driver_app/features/auth/data/model/data_dto.dart';
import 'package:driver_app/features/auth/data/model/request/login_request/login_request.dart';
import 'package:driver_app/features/auth/data/model/response/login_response/login_response.dart';
import 'package:driver_app/features/auth/data/model/user_dto.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_credentials.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_entity.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockTokenStorageService extends Mock implements TokenStorageService {}

class FakeApplicationRequestDto extends Fake implements ApplicationRequestDto {}

class FakeLoginRequest extends Fake implements LoginRequest {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeApplicationRequestDto());
    registerFallbackValue(FakeLoginRequest());
  });

  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockTokenStorageService mockTokenStorageService;
  late AuthRepoImpl repoImpl;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockTokenStorageService = MockTokenStorageService();
    repoImpl = AuthRepoImpl(mockRemoteDataSource, mockTokenStorageService);
  });

  group('AuthRepoImpl - addApplication', () {
    const applicationEntity = ApplicationEntity(
      countryCode: '+20',
      firstName: 'John',
      secondName: 'Doe',
      vehicleType: '1',
      vehicleNumber: 'ABC 123',
      email: 'john@example.com',
      phoneNumber: '01234567890',
      nationalId: '12345678901234',
      password: 'password123',
      confirmPassword: 'password123',
      gender: 'Male',
      vehicleLicencePath: 'license.jpg',
      idImagePath: 'id.jpg',
    );

    test(
      'returns Success<void> when remote data source returns Success',
      () async {
        const responseDto = ApplicationResponseDto(
          success: true,
          message: 'Success',
        );

        when(
          () => mockRemoteDataSource.addApplication(any()),
        ).thenAnswer((_) async => const Success(responseDto));

        final result = await repoImpl.addApplication(applicationEntity);

        expect(result, isA<Success<void>>());
        verify(() => mockRemoteDataSource.addApplication(any())).called(1);
      },
    );

    test('returns Error when remote data source returns Error', () async {
      const failure = ServerFailure();

      when(
        () => mockRemoteDataSource.addApplication(any()),
      ).thenAnswer((_) async => const Error(failure));

      final result = await repoImpl.addApplication(applicationEntity);

      expect(result, isA<Error<void>>());
      expect((result as Error<void>).failure, failure);
      verify(() => mockRemoteDataSource.addApplication(any())).called(1);
    });
  });

  group('AuthRepoImpl - login with rememberMe', () {
    const credentials = LoginCredentials(
      email: 'driver@flowery.com',
      password: 'Password123!',
    );

    final loginResponse = LoginResponse(
      isSuccess: true,
      data: LoginDataDto(
        accessToken: 'mock_access_token',
        refreshToken: 'mock_refresh_token',
        expiresIn: 3600,
        driverStatus: 'Approved',
        user: UserDto(role: 'Driver'),
      ),
    );

    test(
      'persists tokens and saves remembered email when rememberMe is true',
      () async {
        when(
          () => mockRemoteDataSource.login(any()),
        ).thenAnswer((_) async => loginResponse);
        when(
          () => mockTokenStorageService.saveAccessToken(
            any(),
            persist: any(named: 'persist'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockTokenStorageService.saveRefreshToken(
            any(),
            persist: any(named: 'persist'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockTokenStorageService.saveRememberedEmail(any()),
        ).thenAnswer((_) async {});

        final result = await repoImpl.login(credentials, rememberMe: true);

        expect(result, isA<Success<LoginEntity>>());
        verify(
          () => mockTokenStorageService.saveAccessToken(
            'mock_access_token',
            persist: true,
          ),
        ).called(1);
        verify(
          () => mockTokenStorageService.saveRefreshToken(
            'mock_refresh_token',
            persist: true,
          ),
        ).called(1);
        verify(
          () =>
              mockTokenStorageService.saveRememberedEmail('driver@flowery.com'),
        ).called(1);
        verifyNever(() => mockTokenStorageService.deleteRememberedEmail());
      },
    );

    test(
      'does not persist tokens and deletes remembered email when rememberMe is false',
      () async {
        when(
          () => mockRemoteDataSource.login(any()),
        ).thenAnswer((_) async => loginResponse);
        when(
          () => mockTokenStorageService.saveAccessToken(
            any(),
            persist: any(named: 'persist'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockTokenStorageService.saveRefreshToken(
            any(),
            persist: any(named: 'persist'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockTokenStorageService.deleteRememberedEmail(),
        ).thenAnswer((_) async {});

        final result = await repoImpl.login(credentials, rememberMe: false);

        expect(result, isA<Success<LoginEntity>>());
        verify(
          () => mockTokenStorageService.saveAccessToken(
            'mock_access_token',
            persist: false,
          ),
        ).called(1);
        verify(
          () => mockTokenStorageService.saveRefreshToken(
            'mock_refresh_token',
            persist: false,
          ),
        ).called(1);
        verify(() => mockTokenStorageService.deleteRememberedEmail()).called(1);
        verifyNever(() => mockTokenStorageService.saveRememberedEmail(any()));
      },
    );
  });

  group('AuthRepoImpl - remembered email operations', () {
    test('saveRememberedEmail delegates to TokenStorageService', () async {
      when(
        () => mockTokenStorageService.saveRememberedEmail(any()),
      ).thenAnswer((_) async {});

      await repoImpl.saveRememberedEmail('driver@flowery.com');

      verify(
        () => mockTokenStorageService.saveRememberedEmail('driver@flowery.com'),
      ).called(1);
    });

    test('deleteRememberedEmail delegates to TokenStorageService', () async {
      when(
        () => mockTokenStorageService.deleteRememberedEmail(),
      ).thenAnswer((_) async {});

      await repoImpl.deleteRememberedEmail();

      verify(() => mockTokenStorageService.deleteRememberedEmail()).called(1);
    });

    test('loadRememberedEmail delegates to TokenStorageService', () async {
      when(
        () => mockTokenStorageService.getRememberedEmail(),
      ).thenAnswer((_) async => 'driver@flowery.com');

      final result = await repoImpl.loadRememberedEmail();

      expect(result, 'driver@flowery.com');
      verify(() => mockTokenStorageService.getRememberedEmail()).called(1);
    });
  });
}
