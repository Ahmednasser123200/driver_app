import 'dart:async';

import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/forget_password_entity.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/reset_passsword_entity.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/verify_oto_entity.dart';
import 'package:driver_app/features/auth/domain/use_case/forget_password_use_case.dart';
import 'package:driver_app/features/auth/domain/use_case/reset_password_use_case.dart';
import 'package:driver_app/features/auth/domain/use_case/verify_otp_use_case.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_cubit.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_event.dart';
import 'package:driver_app/features/auth/presentation/forget_password/manager/cubit/forget_password_state.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockForgetPasswordUserCase extends Mock
    implements ForgetPasswordUserCase {}

class MockVerifyOtpUserCase extends Mock implements VerifyOtpUseCase {}

class MockResetPasswordUserCase extends Mock implements ResetPasswordUserCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const email = 'driver@example.com';
  const otp = '123456';
  const password = 'Passw0rd!';
  const resetToken = 'token-abc';

  late MockForgetPasswordUserCase forgetUserCase;
  late MockVerifyOtpUserCase verifyUserCase;
  late MockResetPasswordUserCase resetUserCase;
  late ForgetPasswordCubit cubit;
  late List<BaseUiEvent> uiEvents;

  // Stubs live in the tests (never in setUp) so every test controls exactly
  // what the use case returns.
  void stubForgetPassword(BaseResponse<ForgetPasswordEntity> response) {
    when(
          () => forgetUserCase.call(email: any(named: 'email')),
    ).thenAnswer((_) async => response);
  }

  void stubVerifyOtp(BaseResponse<VerifyOtpEntity> response) {
    when(
          () => verifyUserCase.call(
        email: any(named: 'email'),
        otp: any(named: 'otp'),
      ),
    ).thenAnswer((_) async => response);
  }

  void stubResetPassword(BaseResponse<ResetPasswordEntity> response) {
    when(
          () => resetUserCase.call(
        email: any(named: 'email'),
        otp: any(named: 'otp'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => response);
  }

  BaseResponse<ForgetPasswordEntity> sentOk() => Success<ForgetPasswordEntity>(
    ForgetPasswordEntity(isSuccess: true, message: 'sent'),
  );

  BaseResponse<VerifyOtpEntity> verifiedOk() => Success<VerifyOtpEntity>(
    VerifyOtpEntity(resetToken: resetToken, expiresAtUtc: DateTime(2026, 1, 1)),
  );

  BaseResponse<ResetPasswordEntity> resetOk() => Success<ResetPasswordEntity>(
    ResetPasswordEntity(isSuccess: true, message: 'Password updated'),
  );

  setUp(() {
    forgetUserCase = MockForgetPasswordUserCase();
    verifyUserCase = MockVerifyOtpUserCase();
    resetUserCase = MockResetPasswordUserCase();
    cubit = ForgetPasswordCubit(forgetUserCase, verifyUserCase, resetUserCase);
    uiEvents = [];
    cubit.uiEventStream.listen(uiEvents.add);
  });

  tearDown(() => cubit.close());

  T firstEventOfType<T extends BaseUiEvent>() => uiEvents.whereType<T>().first;

  Future<void> sendForgetPassword() async {
    await cubit.doEvent(ForgetPasswordEvent(email: email));
    await pumpEventQueue();
  }

  Future<void> sendResendOtp() async {
    await cubit.doEvent(ResendOtpEvent(email: email));
    await pumpEventQueue();
  }

  Future<void> sendVerifyOtp() async {
    await cubit.doEvent(VerifyOtpEvent(otpCode: otp, email: email));
    await pumpEventQueue();
  }

  Future<void> sendResetPassword() async {
    await cubit.doEvent(
      ResetPasswordEvent(
        email: email,
        newPassword: password,
        resetCode: resetToken,
      ),
    );
    await pumpEventQueue();
  }

  group('forget password', () {
    test('delegates to the use case and stores the email', () async {
      stubForgetPassword(sentOk());

      await sendForgetPassword();

      verify(() => forgetUserCase.call(email: email)).called(1);
      expect(cubit.state.email, email);
      expect(cubit.state.forgotState.isLoading, isFalse);
      expect(cubit.state.forgotState.failure, isNull);
      expect(cubit.state.forgotState.data?.message, 'sent');
    });

    test('is loading while the request is in flight', () async {
      final completer = Completer<BaseResponse<ForgetPasswordEntity>>();
      when(
            () => forgetUserCase.call(email: any(named: 'email')),
      ).thenAnswer((_) => completer.future);

      final pending = cubit.doEvent(ForgetPasswordEvent(email: email));
      await pumpEventQueue();
      expect(cubit.state.forgotState.isLoading, isTrue);

      completer.complete(sentOk());
      await pending;
      await pumpEventQueue();
      expect(cubit.state.forgotState.isLoading, isFalse);
    });

    test('shows the success message then asks the UI to go to verification', () async {
      stubForgetPassword(sentOk());

      await sendForgetPassword();

      expect(uiEvents, [
        isA<ShowSuccessMessage>().having((e) => e.message, 'message', 'sent'),
        isA<ForgetPasswordGoToVerification>(),
      ]);
      expect(uiEvents.whereType<NavigateTo>(), isEmpty);
    });

    test('starts the resend cooldown on success', () async {
      stubForgetPassword(sentOk());

      await sendForgetPassword();

      expect(
        cubit.state.resendSecondsRemaining,
        OtpPolicy.resendCooldownSeconds,
      );
      expect(cubit.state.canResendOtp, isFalse);
    });

    test('surfaces a server failure without navigating', () async {
      stubForgetPassword(
        const Error<ForgetPasswordEntity>(NotFoundFailure()),
      );

      await sendForgetPassword();

      expect(cubit.state.forgotState.isLoading, isFalse);
      expect(cubit.state.forgotState.failure, isA<NotFoundFailure>());
      expect(
        firstEventOfType<ShowErrorMessage>().failure,
        isA<NotFoundFailure>(),
      );
      expect(uiEvents.whereType<ForgetPasswordGoToVerification>(), isEmpty);
      expect(cubit.state.canResendOtp, isTrue);
    });
  });

  group('resend otp', () {
    test('delegates to the use case and tracks its own state slot', () async {
      stubForgetPassword(sentOk());

      await sendResendOtp();

      verify(() => forgetUserCase.call(email: email)).called(1);
      expect(cubit.state.resendOtpState.isLoading, isFalse);
      expect(cubit.state.resendOtpState.failure, isNull);
      expect(cubit.state.forgotState.data, isNull);
    });

    test('shows the success message and does not navigate', () async {
      stubForgetPassword(sentOk());

      await sendResendOtp();

      expect(uiEvents, [
        isA<ShowSuccessMessage>().having((e) => e.message, 'message', 'sent'),
      ]);
    });

    test('restarts the cooldown on success', () async {
      stubForgetPassword(sentOk());

      await sendResendOtp();

      expect(
        cubit.state.resendSecondsRemaining,
        OtpPolicy.resendCooldownSeconds,
      );
      expect(cubit.state.canResendOtp, isFalse);
    });

    test('surfaces a failure and leaves the cooldown untouched', () async {
      stubForgetPassword(
        const Error<ForgetPasswordEntity>(TooManyRequestsFailure()),
      );

      await sendResendOtp();

      expect(cubit.state.resendOtpState.failure, isA<TooManyRequestsFailure>());
      expect(
        firstEventOfType<ShowErrorMessage>().failure,
        isA<TooManyRequestsFailure>(),
      );
      expect(cubit.state.resendSecondsRemaining, 0);
      expect(cubit.state.canResendOtp, isTrue);
    });
  });

  group('resend cooldown', () {
    test('counts down from 30 seconds to zero', () {
      fakeAsync((async) {
        stubForgetPassword(sentOk());

        cubit.doEvent(ForgetPasswordEvent(email: email));
        async.flushMicrotasks();

        expect(
          cubit.state.resendSecondsRemaining,
          OtpPolicy.resendCooldownSeconds,
        );
        expect(cubit.state.canResendOtp, isFalse);

        async.elapse(const Duration(seconds: 5));
        expect(cubit.state.resendSecondsRemaining, 25);
        expect(cubit.state.canResendOtp, isFalse);

        async.elapse(const Duration(seconds: 25));
        expect(cubit.state.resendSecondsRemaining, 0);
        expect(cubit.state.canResendOtp, isTrue);
      });
    });

    test('a successful resend restarts the countdown from 30', () {
      fakeAsync((async) {
        stubForgetPassword(sentOk());

        cubit.doEvent(ForgetPasswordEvent(email: email));
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 10));
        expect(cubit.state.resendSecondsRemaining, 20);

        cubit.doEvent(ResendOtpEvent(email: email));
        async.flushMicrotasks();

        expect(
          cubit.state.resendSecondsRemaining,
          OtpPolicy.resendCooldownSeconds,
        );

        async.elapse(const Duration(seconds: OtpPolicy.resendCooldownSeconds));
        expect(cubit.state.resendSecondsRemaining, 0);
      });
    });

    test('stops ticking once the cubit is closed', () {
      fakeAsync((async) {
        stubForgetPassword(sentOk());
        // A dedicated cubit with no stream listeners, so its close() future
        // completes inside the fake clock instead of waiting on real time.
        final closingCubit = ForgetPasswordCubit(
          forgetUserCase,
          verifyUserCase,
          resetUserCase,
        );

        closingCubit.doEvent(ForgetPasswordEvent(email: email));
        async.flushMicrotasks();
        expect(async.periodicTimerCount, 1);

        closingCubit.close();
        async.flushMicrotasks();

        expect(async.periodicTimerCount, 0);
      });
    });
  });

  group('verify otp', () {
    test('delegates to the use case', () async {
      stubVerifyOtp(verifiedOk());

      await sendVerifyOtp();

      verify(() => verifyUserCase.call(email: email, otp: otp)).called(1);
    });

    test('stores the reset token and asks the UI to go to reset', () async {
      stubVerifyOtp(verifiedOk());

      await sendVerifyOtp();

      expect(cubit.state.otpState.isLoading, isFalse);
      expect(cubit.state.otpState.failure, isNull);
      expect(cubit.state.otpState.data?.resetToken, resetToken);
      expect(uiEvents, [isA<ForgetPasswordGoToReset>()]);
    });

    test('surfaces a wrong-code failure and clears the field', () async {
      stubVerifyOtp(const Error<VerifyOtpEntity>(BadRequestFailure()));

      await sendVerifyOtp();

      expect(cubit.state.otpState.isLoading, isFalse);
      expect(cubit.state.otpState.data, isNull);
      expect(cubit.state.otpState.failure, isA<BadRequestFailure>());
      expect(uiEvents, [
        isA<ClearOtpField>(),
        isA<ShowErrorMessage>().having(
              (e) => e.failure,
          'failure',
          isA<BadRequestFailure>(),
        ),
      ]);
      expect(uiEvents.whereType<ForgetPasswordGoToReset>(), isEmpty);
    });

    test('shows the failure the backend sends, such as a rate limit', () async {
      stubVerifyOtp(const Error<VerifyOtpEntity>(TooManyRequestsFailure()));

      await sendVerifyOtp();

      expect(cubit.state.otpState.failure, isA<TooManyRequestsFailure>());
      expect(
        uiEvents.whereType<ShowErrorMessage>().single.failure,
        isA<TooManyRequestsFailure>(),
      );
    });

    test('attempt limiting is left to the backend', () async {
      stubVerifyOtp(const Error<VerifyOtpEntity>(BadRequestFailure()));

      for (var i = 0; i < 8; i++) {
        await sendVerifyOtp();
      }

      verify(() => verifyUserCase.call(email: email, otp: otp)).called(8);
    });

    test('a later success clears the previous failure', () async {
      stubVerifyOtp(const Error<VerifyOtpEntity>(BadRequestFailure()));
      await sendVerifyOtp();
      expect(cubit.state.otpState.failure, isNotNull);

      stubVerifyOtp(verifiedOk());
      await sendVerifyOtp();

      expect(cubit.state.otpState.failure, isNull);
      expect(cubit.state.otpState.data?.resetToken, resetToken);
    });
  });

  group('reset password', () {
    test('passes the email, reset token and new password through', () async {
      stubResetPassword(resetOk());

      await sendResetPassword();

      verify(
            () => resetUserCase.call(
          email: email,
          otp: resetToken,
          password: password,
        ),
      ).called(1);
    });

    test('shows the success message and navigates to login', () async {
      stubResetPassword(resetOk());

      await sendResetPassword();

      expect(cubit.state.resetState.isLoading, isFalse);
      expect(cubit.state.resetState.failure, isNull);
      expect(
        firstEventOfType<ShowSuccessMessage>().message,
        'Password updated',
      );
      expect(firstEventOfType<NavigateTo>().routeName, Routes.login);
    });

    test('surfaces a server failure without navigating', () async {
      stubResetPassword(const Error<ResetPasswordEntity>(ConflictFailure()));

      await sendResetPassword();

      expect(cubit.state.resetState.isLoading, isFalse);
      expect(cubit.state.resetState.failure, isA<ConflictFailure>());
      expect(
        firstEventOfType<ShowErrorMessage>().failure,
        isA<ConflictFailure>(),
      );
      expect(uiEvents.whereType<NavigateTo>(), isEmpty);
    });
  });
}