import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_credentials.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_entity.dart';
import 'package:driver_app/features/auth/domain/use_case/delete_remembered_email_use_case.dart';
import 'package:driver_app/features/auth/domain/use_case/load_remembered_email_use_case.dart';
import 'package:driver_app/features/auth/domain/use_case/login_use_case.dart';
import 'package:driver_app/features/auth/domain/use_case/save_remembered_email_use_case.dart';
import 'package:driver_app/features/auth/presentation/login/manager/login_cubit.dart';
import 'package:driver_app/features/auth/presentation/login/manager/login_intent.dart';
import 'package:driver_app/features/auth/presentation/login/manager/login_state.dart';
import 'package:driver_app/features/auth/presentation/login/manager/login_ui_event.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockSaveRememberedEmailUseCase extends Mock implements SaveRememberedEmailUseCase {}
class MockDeleteRememberedEmailUseCase extends Mock implements DeleteRememberedEmailUseCase {}
class MockLoadRememberedEmailUseCase extends Mock implements LoadRememberedEmailUseCase {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockSaveRememberedEmailUseCase mockSaveRememberedEmailUseCase;
  late MockDeleteRememberedEmailUseCase mockDeleteRememberedEmailUseCase;
  late MockLoadRememberedEmailUseCase mockLoadRememberedEmailUseCase;

  setUpAll(() {
    registerFallbackValue(
      const LoginCredentials(email: '', password: ''),
    );
  });

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockSaveRememberedEmailUseCase = MockSaveRememberedEmailUseCase();
    mockDeleteRememberedEmailUseCase = MockDeleteRememberedEmailUseCase();
    mockLoadRememberedEmailUseCase = MockLoadRememberedEmailUseCase();
  });

  LoginCubit createCubit() => LoginCubit(
        mockLoginUseCase,
        mockSaveRememberedEmailUseCase,
        mockDeleteRememberedEmailUseCase,
        mockLoadRememberedEmailUseCase,
      );

  group('LoginCubit Initial State', () {
    test('initial state has default values', () {
      final loginCubit = createCubit();
      expect(loginCubit.state, equals(const LoginState()));
      expect(loginCubit.state.email, isEmpty);
      expect(loginCubit.state.password, isEmpty);
      expect(loginCubit.state.rememberMe, isFalse);
      expect(loginCubit.state.obscurePassword, isTrue);
      expect(loginCubit.state.isLoading, isFalse);
      expect(loginCubit.state.errorMessage, isEmpty);
      loginCubit.close();
    });
  });

  group('LoginCubit Handle Intents', () {
    blocTest<LoginCubit, LoginState>(
      'emits updated email when EmailChanged intent is sent',
      build: createCubit,
      act: (cubit) => cubit.handle(EmailChanged('test@driver.com')),
      expect: () => [
        const LoginState(email: 'test@driver.com', errorMessage: ''),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits updated password when PasswordChanged intent is sent',
      build: createCubit,
      act: (cubit) => cubit.handle(PasswordChanged('password123')),
      expect: () => [
        const LoginState(password: 'password123', errorMessage: ''),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits updated rememberMe when RememberMeChanged intent is sent',
      build: createCubit,
      act: (cubit) => cubit.handle(RememberMeChanged(true)),
      expect: () => [
        const LoginState(rememberMe: true),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'toggles obscurePassword when TogglePasswordVisibility intent is sent',
      build: createCubit,
      act: (cubit) => cubit.handle(TogglePasswordVisibility()),
      expect: () => [
        const LoginState(obscurePassword: false),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'loads saved email and emits EmailPreFilledEvent when LoadRememberedEmail intent is sent and saved email exists',
      setUp: () {
        when(() => mockLoadRememberedEmailUseCase())
            .thenAnswer((_) async => 'saved@driver.com');
      },
      build: createCubit,
      act: (cubit) => cubit.handle(LoadRememberedEmail()),
      expect: () => [
        const LoginState(email: 'saved@driver.com', rememberMe: true),
      ],
      verify: (_) {
        verify(() => mockLoadRememberedEmailUseCase()).called(1);
      },
    );

    test('emits EmailPreFilledEvent UI event on LoadRememberedEmail when saved email exists', () async {
      when(() => mockLoadRememberedEmailUseCase())
          .thenAnswer((_) async => 'saved@driver.com');

      final loginCubit = createCubit();
      final events = <BaseUiEvent>[];
      final subscription = loginCubit.uiEventStream.listen(events.add);

      await loginCubit.handle(LoadRememberedEmail());
      await Future.delayed(Duration.zero);

      expect(events.length, equals(1));
      expect(events[0], isA<EmailPreFilledEvent>());
      expect((events[0] as EmailPreFilledEvent).email, equals('saved@driver.com'));

      await subscription.cancel();
      await loginCubit.close();
    });

    blocTest<LoginCubit, LoginState>(
      'does not emit new state on LoadRememberedEmail when no saved email exists',
      setUp: () {
        when(() => mockLoadRememberedEmailUseCase())
            .thenAnswer((_) async => null);
      },
      build: createCubit,
      act: (cubit) => cubit.handle(LoadRememberedEmail()),
      expect: () => const <LoginState>[],
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
      'emits loading and success states, and saves email when rememberMe is true',
      setUp: () {
        when(
          () => mockLoginUseCase(any(), rememberMe: any(named: 'rememberMe')),
        ).thenAnswer((_) async => const Success(loginEntityApproved));
        when(() => mockSaveRememberedEmailUseCase(any())).thenAnswer((_) async {});
      },
      build: createCubit,
      seed: () => const LoginState(
        email: 'driver@example.com',
        password: 'pass123',
        rememberMe: true,
      ),
      act: (cubit) => cubit.handle(LoginSubmitted()),
      expect: () => [
        const LoginState(
          email: 'driver@example.com',
          password: 'pass123',
          rememberMe: true,
          isLoading: true,
          errorMessage: '',
          loginSuccess: false,
        ),
        const LoginState(
          email: 'driver@example.com',
          password: 'pass123',
          rememberMe: true,
          isLoading: false,
          data: loginEntityApproved,
          loginSuccess: true,
        ),
      ],
      verify: (_) {
        verify(() => mockSaveRememberedEmailUseCase('driver@example.com')).called(1);
        verifyNever(() => mockDeleteRememberedEmailUseCase());
      },
    );

    blocTest<LoginCubit, LoginState>(
      'emits loading and success states, and deletes remembered email when rememberMe is false',
      setUp: () {
        when(
          () => mockLoginUseCase(any(), rememberMe: any(named: 'rememberMe')),
        ).thenAnswer((_) async => const Success(loginEntityApproved));
        when(() => mockDeleteRememberedEmailUseCase()).thenAnswer((_) async {});
      },
      build: createCubit,
      seed: () => const LoginState(
        email: 'driver@example.com',
        password: 'pass123',
        rememberMe: false,
      ),
      act: (cubit) => cubit.handle(LoginSubmitted()),
      expect: () => [
        const LoginState(
          email: 'driver@example.com',
          password: 'pass123',
          rememberMe: false,
          isLoading: true,
          errorMessage: '',
          loginSuccess: false,
        ),
        const LoginState(
          email: 'driver@example.com',
          password: 'pass123',
          rememberMe: false,
          isLoading: false,
          data: loginEntityApproved,
          loginSuccess: true,
        ),
      ],
      verify: (_) {
        verify(() => mockDeleteRememberedEmailUseCase()).called(1);
        verifyNever(() => mockSaveRememberedEmailUseCase(any()));
      },
    );

    test('emits ShowSuccessMessage and ShowErrorMessage when driverStatus is pending', () async {
      when(
        () => mockLoginUseCase(any(), rememberMe: any(named: 'rememberMe')),
      ).thenAnswer((_) async => const Success(loginEntityPending));
      when(() => mockDeleteRememberedEmailUseCase()).thenAnswer((_) async {});

      final loginCubit = createCubit();
      final events = <BaseUiEvent>[];
      final subscription = loginCubit.uiEventStream.listen(events.add);

      loginCubit.handle(EmailChanged('driver@example.com'));
      loginCubit.handle(PasswordChanged('pass123'));
      await loginCubit.handle(LoginSubmitted());
      await Future.delayed(Duration.zero);

      expect(events.length, equals(2));
      expect(events[0], isA<ShowSuccessMessage>());
      expect((events[0] as ShowSuccessMessage).message, equals(AppStrings.loggedInSuccessfully));
      expect(events[1], isA<ShowErrorMessage>());
      expect((events[1] as ShowErrorMessage).message, equals(AppStrings.loginFailed));

      await subscription.cancel();
      await loginCubit.close();
    });

    test('emits ShowSuccessMessage and NavigateTo home when driverStatus is approved', () async {
      when(
        () => mockLoginUseCase(any(), rememberMe: any(named: 'rememberMe')),
      ).thenAnswer((_) async => const Success(loginEntityApproved));
      when(() => mockDeleteRememberedEmailUseCase()).thenAnswer((_) async {});

      final loginCubit = createCubit();
      final events = <BaseUiEvent>[];
      final subscription = loginCubit.uiEventStream.listen(events.add);

      loginCubit.handle(EmailChanged('driver@example.com'));
      loginCubit.handle(PasswordChanged('pass123'));
      await loginCubit.handle(LoginSubmitted());
      await Future.delayed(Duration.zero);

      expect(events.length, equals(2));
      expect(events[0], isA<ShowSuccessMessage>());
      expect(events[1], isA<NavigateTo>());
      expect((events[1] as NavigateTo).routeName, equals(Routes.home));

      await subscription.cancel();
      await loginCubit.close();
    });
  });

  group('LoginCubit LoginSubmitted Error Flows', () {
    test('emits ShowErrorMessage with failure when login fails', () async {
      const failure = BadRequestFailure(serverMessage: 'Invalid credentials');
      when(
        () => mockLoginUseCase(any(), rememberMe: any(named: 'rememberMe')),
      ).thenAnswer((_) async => const Error(failure));

      final loginCubit = createCubit();
      final events = <BaseUiEvent>[];
      final subscription = loginCubit.uiEventStream.listen(events.add);

      loginCubit.handle(EmailChanged('driver@example.com'));
      loginCubit.handle(PasswordChanged('wrongpass'));
      await loginCubit.handle(LoginSubmitted());
      await Future.delayed(Duration.zero);

      expect(events.length, equals(1));
      expect(events[0], isA<ShowErrorMessage>());
      expect((events[0] as ShowErrorMessage).failure, equals(failure));

      await subscription.cancel();
      await loginCubit.close();
    });
  });
}