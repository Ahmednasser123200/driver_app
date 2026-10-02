import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_credentials.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_entity.dart';
import 'package:driver_app/features/auth/domain/repo/auth_repo.dart';
import 'package:driver_app/features/auth/domain/use_case/delete_remembered_email_use_case.dart';
import 'package:driver_app/features/auth/domain/use_case/load_remembered_email_use_case.dart';
import 'package:driver_app/features/auth/domain/use_case/login_use_case.dart';
import 'package:driver_app/features/auth/domain/use_case/save_remembered_email_use_case.dart';

class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late MockAuthRepo mockAuthRepo;
  late LoginUseCase loginUseCase;
  late LoadRememberedEmailUseCase loadRememberedEmailUseCase;
  late SaveRememberedEmailUseCase saveRememberedEmailUseCase;
  late DeleteRememberedEmailUseCase deleteRememberedEmailUseCase;

  setUpAll(() {
    registerFallbackValue(
      const LoginCredentials(email: '', password: ''),
    );
  });

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    loginUseCase = LoginUseCase(mockAuthRepo);
    loadRememberedEmailUseCase = LoadRememberedEmailUseCase(mockAuthRepo);
    saveRememberedEmailUseCase = SaveRememberedEmailUseCase(mockAuthRepo);
    deleteRememberedEmailUseCase = DeleteRememberedEmailUseCase(mockAuthRepo);
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

  group('LoadRememberedEmailUseCase', () {
    test('delegates call to AuthRepo.getRememberedEmail and returns saved email', () async {
      when(() => mockAuthRepo.getRememberedEmail()).thenAnswer((_) async => 'saved@driver.com');

      final result = await loadRememberedEmailUseCase();

      expect(result, equals('saved@driver.com'));
      verify(() => mockAuthRepo.getRememberedEmail()).called(1);
    });
  });

  group('SaveRememberedEmailUseCase', () {
    test('delegates call to AuthRepo.saveRememberedEmail with given email', () async {
      when(() => mockAuthRepo.saveRememberedEmail(any())).thenAnswer((_) async {});

      await saveRememberedEmailUseCase('new@driver.com');

      verify(() => mockAuthRepo.saveRememberedEmail('new@driver.com')).called(1);
    });
  });

  group('DeleteRememberedEmailUseCase', () {
    test('delegates call to AuthRepo.deleteRememberedEmail', () async {
      when(() => mockAuthRepo.deleteRememberedEmail()).thenAnswer((_) async {});

      await deleteRememberedEmailUseCase();

      verify(() => mockAuthRepo.deleteRememberedEmail()).called(1);
    });
  });
}
