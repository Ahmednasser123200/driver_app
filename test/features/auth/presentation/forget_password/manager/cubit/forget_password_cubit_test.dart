import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/forget_password_entity.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/reset_passsword_entity.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/verify_oto_entity.dart';
import 'package:driver_app/features/auth/domain/use_case/forget_password_user_case.dart';
import 'package:driver_app/features/auth/domain/use_case/reset_password_user_case.dart';
import 'package:driver_app/features/auth/domain/use_case/verify_otp_user_case.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_cubit.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_event.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_state.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../helpers/mockito_dummies.dart';
import 'forget_password_cubit_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<ForgetPasswordUserCase>(),
  MockSpec<VerifyOtpUserCase>(),
  MockSpec<ResetPasswordUserCase>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const email = 'driver@example.com';
  const otp = '123456';
  const password = 'Passw0rd!';

  late MockForgetPasswordUserCase forgetUserCase;
  late MockVerifyOtpUserCase verifyUserCase;
  late MockResetPasswordUserCase resetUserCase;
  late ForgetPasswordCubit cubit;
  late List<BaseUiEvent> uiEvents;

  void stubVerifyOtp(Future<BaseResponse<dynamic>> Function() answer) {
    when(
      verifyUserCase.call(email: anyNamed('email'), otp: anyNamed('otp')),
    ).thenAnswer((_) => answer());
  }

  void stubForgetPassword(Future<BaseResponse<dynamic>> Function() answer) {
    when(
      forgetUserCase.call(email: anyNamed('email')),
    ).thenAnswer((_) => answer());
  }

  void stubResetPassword(
    Future<BaseResponse<ResetPassswordEntity>> Function() answer,
  ) {
    when(
      resetUserCase.call(
        email: anyNamed('email'),
        otp: anyNamed('otp'),
        password: anyNamed('password'),
      ),
    ).thenAnswer((_) => answer());
  }

  Future<BaseResponse<dynamic>> sentOk() async =>
      Success<dynamic>(ForgetPasswordEntity(isSuccess: true, message: 'sent'));

  setUp(() {
    registerAuthDummies();
    forgetUserCase = MockForgetPasswordUserCase();
    verifyUserCase = MockVerifyOtpUserCase();
    resetUserCase = MockResetPasswordUserCase();
    cubit = ForgetPasswordCubit(forgetUserCase, verifyUserCase, resetUserCase);
    uiEvents = [];
    cubit.uiEventStream.listen(uiEvents.add);

    stubVerifyOtp(() async => const Error<dynamic>(BadRequestFailure()));
  });

  tearDown(() => cubit.close());

  Future<void> verifyOnce() async {
    await cubit.doEvent(VerifyOtpEvent(otpCode: otp, email: email));
    await pumpEventQueue();
  }

  T firstEventOfType<T extends BaseUiEvent>() => uiEvents.whereType<T>().first;

  group('forget password', () {
    test('rejects an empty email without calling the repo', () async {
      await cubit.doEvent(ForgetBassEvent(email: ''));
      await pumpEventQueue();

      expect(cubit.state.forgotstate.errorMessage, isNotEmpty);
      expect(cubit.state.forgotstate.isLoading, isFalse);
      verifyNever(forgetUserCase.call(email: anyNamed('email')));
      expect(firstEventOfType<ShowErrorMessage>(), isA<ShowErrorMessage>());
    });

    test('rejects a malformed email without calling the repo', () async {
      await cubit.doEvent(ForgetBassEvent(email: 'not-an-email'));
      await pumpEventQueue();

      expect(cubit.state.forgotstate.errorMessage, isNotEmpty);
      verifyNever(forgetUserCase.call(email: anyNamed('email')));
    });

    test('navigates to verification carrying the email', () async {
      stubForgetPassword(sentOk);

      await cubit.doEvent(ForgetBassEvent(email: email));
      await pumpEventQueue();

      expect(cubit.state.forgotstate.isLoading, isFalse);
      expect(cubit.state.forgotstate.errorMessage, isEmpty);

      final navigate = firstEventOfType<NavigateTo>();
      expect(navigate.routeName, Routes.verificationCode);
      expect(navigate.arguments, {'email': email});
      expect(firstEventOfType<ShowSuccessMessage>().message, 'sent');
    });

    test('surfaces a server failure', () async {
      stubForgetPassword(() async => const Error<dynamic>(NotFoundFailure()));

      await cubit.doEvent(ForgetBassEvent(email: email));
      await pumpEventQueue();

      expect(cubit.state.forgotstate.errorMessage, isNotEmpty);
      expect(firstEventOfType<ShowErrorMessage>(), isA<ShowErrorMessage>());
      expect(uiEvents.whereType<NavigateTo>(), isEmpty);
    });
  });

  group('resend otp', () {
    test('restarts the cooldown and restores the attempt budget', () async {
      for (var i = 0; i < OtpPolicy.maxVerifyAttempts; i++) {
        await verifyOnce();
      }
      expect(cubit.state.isOtpLockedOut, isTrue);

      stubForgetPassword(sentOk);

      await cubit.doEvent(ResendOtpEvent(email: email));
      await pumpEventQueue();

      expect(cubit.state.isOtpLockedOut, isFalse);
      expect(cubit.state.verifyAttemptsRemaining, OtpPolicy.maxVerifyAttempts);
      expect(
        cubit.state.resendSecondsRemaining,
        OtpPolicy.resendCooldownSeconds,
      );
      expect(cubit.state.canResendOtp, isFalse);
    });

    test('leaves the attempt budget untouched on failure', () async {
      stubForgetPassword(
        () async => const Error<dynamic>(TooManyRequestsFailure()),
      );

      await cubit.doEvent(ResendOtpEvent(email: email));
      await pumpEventQueue();

      expect(cubit.state.verifyAttemptsRemaining, OtpPolicy.maxVerifyAttempts);
      expect(cubit.state.resendOtpState.errorMessage, isNotEmpty);
    });
  });

  group('resend cooldown', () {
    test('starts at 30 seconds and counts down to zero', () {
      fakeAsync((async) {
        expect(cubit.state.resendSecondsRemaining, 0);
        expect(cubit.state.canResendOtp, isTrue);

        cubit.startResendCooldown();

        expect(
          cubit.state.resendSecondsRemaining,
          OtpPolicy.resendCooldownSeconds,
        );
        expect(cubit.state.canResendOtp, isFalse);

        async.elapse(const Duration(seconds: 5));
        expect(cubit.state.resendSecondsRemaining, 25);

        async.elapse(const Duration(seconds: OtpPolicy.resendCooldownSeconds));
        expect(cubit.state.resendSecondsRemaining, 0);
        expect(cubit.state.canResendOtp, isTrue);
      });
    });

    test('does not restart while a cooldown is already running', () {
      fakeAsync((async) {
        cubit.startResendCooldown();
        async.elapse(const Duration(seconds: 10));
        expect(cubit.state.resendSecondsRemaining, 20);

        cubit.startResendCooldown();

        expect(cubit.state.resendSecondsRemaining, 20);
      });
    });
  });

  group('verify otp', () {
    test('rejects an empty otp without calling the repo', () async {
      await cubit.doEvent(VerifyOtpEvent(otpCode: '', email: email));
      await pumpEventQueue();

      expect(cubit.state.otpState.errorMessage, isNotEmpty);
      verifyNever(
        verifyUserCase.call(email: anyNamed('email'), otp: anyNamed('otp')),
      );
    });

    test('navigates to reset carrying the email and the reset token', () async {
      stubVerifyOtp(
        () async => Success<dynamic>(
          VerifyOtpEntity(
            resetToken: 'token-abc',
            expiresAtUtc: DateTime(2026, 1, 1),
          ),
        ),
      );

      await cubit.doEvent(VerifyOtpEvent(otpCode: otp, email: email));
      await pumpEventQueue();

      final navigate = firstEventOfType<NavigateTo>();
      expect(navigate.routeName, Routes.resetPassword);
      expect(navigate.arguments, {'email': email, 'otpcode': 'token-abc'});
      expect(cubit.state.otpState.isLoading, isFalse);
    });

    test('starts with the full attempt budget and is not locked out', () {
      expect(cubit.state.verifyAttemptsRemaining, OtpPolicy.maxVerifyAttempts);
      expect(cubit.state.isOtpLockedOut, isFalse);
    });

    test('each failure consumes exactly one attempt', () async {
      await verifyOnce();

      expect(
        cubit.state.verifyAttemptsRemaining,
        OtpPolicy.maxVerifyAttempts - 1,
      );
      expect(cubit.state.isOtpLockedOut, isFalse);
    });

    test('locks out on the final attempt', () async {
      for (var i = 0; i < OtpPolicy.maxVerifyAttempts; i++) {
        await verifyOnce();
      }

      expect(cubit.state.verifyAttemptsRemaining, 0);
      expect(cubit.state.isOtpLockedOut, isTrue);
    });

    test('never reaches the repo once locked out', () async {
      for (var i = 0; i < OtpPolicy.maxVerifyAttempts; i++) {
        await verifyOnce();
      }
      clearInteractions(verifyUserCase);

      await verifyOnce();

      verifyNever(
        verifyUserCase.call(email: anyNamed('email'), otp: anyNamed('otp')),
      );
      expect(cubit.state.verifyAttemptsRemaining, 0);
      expect(firstEventOfType<ShowErrorMessage>().message, isNotEmpty);
    });
  });

  group('reset password', () {
    test('rejects an empty reset code without calling the repo', () async {
      await cubit.doEvent(
        ResetPasswordEvent(email: email, newPassword: password, resetCode: ''),
      );
      await pumpEventQueue();

      expect(cubit.state.resetstate.errorMessage, isNotEmpty);
      verifyNever(
        resetUserCase.call(
          email: anyNamed('email'),
          otp: anyNamed('otp'),
          password: anyNamed('password'),
        ),
      );
    });

    test('navigates to login on success', () async {
      stubResetPassword(
        () async => Success<ResetPassswordEntity>(
          ResetPassswordEntity(isSuccess: true, message: 'Password updated'),
        ),
      );

      await cubit.doEvent(
        ResetPasswordEvent(
          email: email,
          newPassword: password,
          resetCode: 'token-abc',
        ),
      );
      await pumpEventQueue();

      expect(cubit.state.resetstate.isLoading, isFalse);
      expect(cubit.state.resetstate.errorMessage, isEmpty);
      expect(
        firstEventOfType<ShowSuccessMessage>().message,
        'Password updated',
      );
      expect(firstEventOfType<NavigateTo>().routeName, Routes.login);
    });

    test('surfaces a server failure', () async {
      stubResetPassword(
        () async => const Error<ResetPassswordEntity>(ConflictFailure()),
      );

      await cubit.doEvent(
        ResetPasswordEvent(
          email: email,
          newPassword: password,
          resetCode: 'token-abc',
        ),
      );
      await pumpEventQueue();

      expect(cubit.state.resetstate.errorMessage, isNotEmpty);
      expect(uiEvents.whereType<NavigateTo>(), isEmpty);
    });
  });
}
