import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_credentials.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_entity.dart';
import 'package:driver_app/features/auth/domain/repo/auth_repo.dart';
import 'package:driver_app/features/auth/domain/use_case/login_use_case.dart';

class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late MockAuthRepo mockAuthRepo;
  late LoginUseCase loginUseCase;

  setUpAll(() {
    registerFallbackValue(
      const LoginCredentials(email: '', password: ''),
    );
  });

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    loginUseCase = LoginUseCase(mockAuthRepo);
  });

  group('LoginUseCase', () {
    const credentials = LoginCredentials(
      email: 'test@driver.com',
      password: 'password123',
    );

    const loginEntity = LoginEntity(
      accessToken: 'access',
      refreshToken: 'refresh',
      expiresIn: 3600,
      driverStatus: 'Approved',
    );

    test('calls AuthRepo.login with credentials and default rememberMe=false', () async {
      when(
        () => mockAuthRepo.login(any(), rememberMe: any(named: 'rememberMe')),
      ).thenAnswer((_) async => const Success(loginEntity));

      final result = await loginUseCase(credentials);

      expect(result, isA<Success<LoginEntity>>());
      final success = result as Success<LoginEntity>;
      expect(success.data, equals(loginEntity));

      verify(
        () => mockAuthRepo.login(credentials, rememberMe: false),
      ).called(1);
    });

    test('calls AuthRepo.login with credentials and rememberMe=true', () async {
      when(
        () => mockAuthRepo.login(any(), rememberMe: any(named: 'rememberMe')),
      ).thenAnswer((_) async => const Success(loginEntity));

      final result = await loginUseCase(credentials, rememberMe: true);

      expect(result, isA<Success<LoginEntity>>());

      verify(
        () => mockAuthRepo.login(credentials, rememberMe: true),
      ).called(1);
    });

    test('returns Error when AuthRepo.login returns Error', () async {
      const failure = BadRequestFailure(serverMessage: 'Invalid credentials');
      when(
        () => mockAuthRepo.login(any(), rememberMe: any(named: 'rememberMe')),
      ).thenAnswer((_) async => const Error(failure));

      final result = await loginUseCase(credentials);

      expect(result, isA<Error<LoginEntity>>());
      final error = result as Error<LoginEntity>;
      expect(error.failure, equals(failure));

      verify(
        () => mockAuthRepo.login(credentials, rememberMe: false),
      ).called(1);
    });
  });
}
