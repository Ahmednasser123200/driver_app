import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/features/auth/api/service/secure_storage.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_credentials.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_entity.dart';
import 'package:driver_app/features/auth/domain/use_case/login_use_case.dart';
import 'package:driver_app/features/auth/presentation/login/manager/login_cubit.dart';
import 'package:driver_app/features/auth/presentation/login/manager/login_intent.dart';
import 'package:driver_app/features/auth/presentation/login/manager/login_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockSecureStorageService mockSecureStorage;
  late LoginCubit loginCubit;

  setUpAll(() {
    registerFallbackValue(
      const LoginCredentials(email: '', password: ''),
    );
  });

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockSecureStorage = MockSecureStorageService();
    loginCubit = LoginCubit(mockLoginUseCase, mockSecureStorage);
  });

  tearDown(() {
    loginCubit.close();
  });

  group('LoginCubit Initial State', () {
    test('initial state is correct', () {
      expect(loginCubit.state, equals(const LoginState()));
      expect(loginCubit.state.email, isEmpty);
      expect(loginCubit.state.password, isEmpty);
      expect(loginCubit.state.rememberMe, isFalse);
      expect(loginCubit.state.obscurePassword, isTrue);
      expect(loginCubit.state.isLoading, isFalse);
      expect(loginCubit.state.errorMessage, isEmpty);
    });
  });

  group('LoginCubit Handle Intents', () {
    blocTest<LoginCubit, LoginState>(
      'emits updated email when EmailChanged intent is sent',
      build: () => loginCubit,
      act: (cubit) => cubit.handle(EmailChanged('test@driver.com')),
      expect: () => [
        const LoginState(email: 'test@driver.com', errorMessage: ''),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits updated password when PasswordChanged intent is sent',
      build: () => loginCubit,
      act: (cubit) => cubit.handle(PasswordChanged('password123')),
      expect: () => [
        const LoginState(password: 'password123', errorMessage: ''),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits updated rememberMe when RememberMeChanged intent is sent',
      build: () => loginCubit,
      act: (cubit) => cubit.handle(RememberMeChanged(true)),
      expect: () => [
        const LoginState(rememberMe: true),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'toggles obscurePassword when TogglePasswordVisibility intent is sent',
      build: () => loginCubit,
      act: (cubit) => cubit.handle(TogglePasswordVisibility()),
      expect: () => [
        const LoginState(obscurePassword: false),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'loads saved email and sets rememberMe=true when LoadSavedEmail intent is sent and email exists',
      setUp: () {
        when(() => mockSecureStorage.getRememberedEmail())
            .thenAnswer((_) async => 'saved@driver.com');
      },
      build: () => loginCubit,
      act: (cubit) => cubit.handle(LoadSavedEmail()),
      expect: () => [
        const LoginState(email: 'saved@driver.com', rememberMe: true),
      ],
      verify: (_) {
        verify(() => mockSecureStorage.getRememberedEmail()).called(1);
      },
    );

    blocTest<LoginCubit, LoginState>(
      'does not emit new state on LoadSavedEmail when no saved email exists',
      setUp: () {
        when(() => mockSecureStorage.getRememberedEmail())
            .thenAnswer((_) async => null);
      },
      build: () => loginCubit,
      act: (cubit) => cubit.handle(LoadSavedEmail()),
      expect: () => [],
    );
  });

  group('LoginCubit LoginSubmitted Success Flows', () {
    const loginEntityPending = LoginEntity(
      accessToken: 'access',
      refreshToken: 'refresh',
      expiresIn: 3600,
      driverStatus: 'pending',
    );

    const loginEntityApproved = LoginEntity(
      accessToken: 'access',
      refreshToken: 'refresh',
      expiresIn: 3600,
      driverStatus: 'approved',
    );

    blocTest<LoginCubit, LoginState>(
      'emits loading and success states when login succeeds with pending status',
      setUp: () {
        when(
          () => mockLoginUseCase(any(), rememberMe: any(named: 'rememberMe')),
        ).thenAnswer((_) async => const Success(loginEntityPending));
      },
      build: () => loginCubit,
      seed: () => const LoginState(
        email: 'driver@example.com',
        password: 'pass123',
      ),
      act: (cubit) => cubit.handle(LoginSubmitted()),
      expect: () => [
        const LoginState(
          email: 'driver@example.com',
          password: 'pass123',
          isLoading: true,
          errorMessage: '',
        ),
        const LoginState(
          email: 'driver@example.com',
          password: 'pass123',
          isLoading: false,
          data: loginEntityPending,
        ),
      ],
    );

    test('emits ShowSuccessMessage and NavigateTo successApply when driverStatus is pending', () async {
      when(
        () => mockLoginUseCase(any(), rememberMe: any(named: 'rememberMe')),
      ).thenAnswer((_) async => const Success(loginEntityPending));

      final events = <BaseUiEvent>[];
      final subscription = loginCubit.uiEventStream.listen(events.add);

      loginCubit.handle(EmailChanged('driver@example.com'));
      loginCubit.handle(PasswordChanged('pass123'));
      loginCubit.handle(LoginSubmitted());

      await Future.delayed(Duration.zero);

      expect(events.length, equals(2));
      expect(events[0], isA<ShowSuccessMessage>());
      expect((events[0] as ShowSuccessMessage).message, 'تم تسجيل الدخول بنجاح');
      expect(events[1], isA<NavigateTo>());
      expect((events[1] as NavigateTo).routeName, Routes.successApply);

      await subscription.cancel();
    });

    test('emits NavigateTo home when driverStatus is approved', () async {
      when(
        () => mockLoginUseCase(any(), rememberMe: any(named: 'rememberMe')),
      ).thenAnswer((_) async => const Success(loginEntityApproved));

      final events = <BaseUiEvent>[];
      final subscription = loginCubit.uiEventStream.listen(events.add);

      loginCubit.handle(EmailChanged('driver@example.com'));
      loginCubit.handle(PasswordChanged('pass123'));
      loginCubit.handle(LoginSubmitted());

      await Future.delayed(Duration.zero);

      expect(events.length, equals(2));
      expect(events[1], isA<NavigateTo>());
      expect((events[1] as NavigateTo).routeName, Routes.home);

      await subscription.cancel();
    });
  });

  group('LoginCubit LoginSubmitted Error Flows', () {
    test('handles BadRequestFailure with serverMessage correctly', () async {
      const failure = BadRequestFailure(serverMessage: 'بيانات الدخول غير صحيحة');
      when(
        () => mockLoginUseCase(any(), rememberMe: any(named: 'rememberMe')),
      ).thenAnswer((_) async => const Error(failure));

      final events = <BaseUiEvent>[];
      final subscription = loginCubit.uiEventStream.listen(events.add);

      loginCubit.handle(EmailChanged('driver@example.com'));
      loginCubit.handle(PasswordChanged('wrongpass'));
      loginCubit.handle(LoginSubmitted());

      await Future.delayed(Duration.zero);

      expect(loginCubit.state.errorMessage, 'بيانات الدخول غير صحيحة');
      expect(events.length, equals(1));
      expect(events[0], isA<ShowErrorMessage>());
      expect((events[0] as ShowErrorMessage).message, 'بيانات الدخول غير صحيحة');

      await subscription.cancel();
    });

    test('handles InternetConnectionFailure correctly', () async {
      const failure = InternetConnectionFailure();
      when(
        () => mockLoginUseCase(any(), rememberMe: any(named: 'rememberMe')),
      ).thenAnswer((_) async => const Error(failure));

      final events = <BaseUiEvent>[];
      final subscription = loginCubit.uiEventStream.listen(events.add);

      loginCubit.handle(EmailChanged('driver@example.com'));
      loginCubit.handle(PasswordChanged('pass123'));
      loginCubit.handle(LoginSubmitted());

      await Future.delayed(Duration.zero);

      expect(loginCubit.state.errorMessage, 'تأكد من اتصالك بالإنترنت.');
      expect(events.length, equals(1));
      expect((events[0] as ShowErrorMessage).message, 'تأكد من اتصالك بالإنترنت.');

      await subscription.cancel();
    });

    test('handles TimeoutFailure correctly', () async {
      const failure = TimeoutFailure();
      when(
        () => mockLoginUseCase(any(), rememberMe: any(named: 'rememberMe')),
      ).thenAnswer((_) async => const Error(failure));

      final events = <BaseUiEvent>[];
      final subscription = loginCubit.uiEventStream.listen(events.add);

      loginCubit.handle(LoginSubmitted());

      await Future.delayed(Duration.zero);

      expect(loginCubit.state.errorMessage, 'انتهت مهلة الاتصال بالخادم.');
      expect((events[0] as ShowErrorMessage).message, 'انتهت مهلة الاتصال بالخادم.');

      await subscription.cancel();
    });
  });
}
