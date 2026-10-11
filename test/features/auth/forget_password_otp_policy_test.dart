import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/forget_password_entity.dart';
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

/// Covers the resend-cooldown policy. Every time-based test runs inside
/// `fakeAsync`, so nothing waits on the wall clock.
///
/// Limiting verification attempts is not a client concern: the backend owns it
/// and the cubit just surfaces whatever failure it returns.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const email = 'driver@example.com';

  late MockForgetPasswordUserCase forgetUserCase;
  late MockVerifyOtpUserCase verifyUserCase;
  late MockResetPasswordUserCase resetUserCase;
  late ForgetPasswordCubit cubit;

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

  BaseResponse<ForgetPasswordEntity> sentOk() => Success<ForgetPasswordEntity>(
    ForgetPasswordEntity(isSuccess: true, message: 'sent'),
  );

  setUp(() {
    forgetUserCase = MockForgetPasswordUserCase();
    verifyUserCase = MockVerifyOtpUserCase();
    resetUserCase = MockResetPasswordUserCase();
    cubit = ForgetPasswordCubit(forgetUserCase, verifyUserCase, resetUserCase);
  });

  tearDown(() => cubit.close());

  // Dispatches an event and lets the mocked use case answer, without waiting
  // on real time.
  void dispatch(FakeAsync async, ForgetPasswordAbstractEvent event) {
    cubit.doEvent(event);
    async.flushMicrotasks();
  }

  group('resend cooldown policy', () {
    test('is a 30 second cooldown', () {
      expect(OtpPolicy.resendCooldownSeconds, 30);
    });

    test('resend is available before any code has been sent', () {
      expect(cubit.state.resendSecondsRemaining, 0);
      expect(cubit.state.canResendOtp, isTrue);
    });

    test('resend stays blocked for the full cooldown after a code is sent', () {
      fakeAsync((async) {
        stubForgetPassword(sentOk());

        dispatch(async, ForgetPasswordEvent(email: email));

        async.elapse(const Duration(seconds: 29));
        expect(cubit.state.resendSecondsRemaining, 1);
        expect(cubit.state.canResendOtp, isFalse);

        async.elapse(const Duration(seconds: 1));
        expect(cubit.state.resendSecondsRemaining, 0);
        expect(cubit.state.canResendOtp, isTrue);
      });
    });

    test('a successful resend restarts the cooldown', () {
      fakeAsync((async) {
        stubForgetPassword(sentOk());

        dispatch(async, ForgetPasswordEvent(email: email));
        async.elapse(const Duration(seconds: 20));
        expect(cubit.state.resendSecondsRemaining, 10);
        expect(cubit.state.canResendOtp, isFalse);

        dispatch(async, ResendOtpEvent(email: email));

        expect(
          cubit.state.resendSecondsRemaining,
          OtpPolicy.resendCooldownSeconds,
        );
        expect(cubit.state.canResendOtp, isFalse);

        async.elapse(const Duration(seconds: OtpPolicy.resendCooldownSeconds));
        expect(cubit.state.canResendOtp, isTrue);
      });
    });

    test('a failed resend does not restart the cooldown', () {
      fakeAsync((async) {
        stubForgetPassword(sentOk());
        dispatch(async, ForgetPasswordEvent(email: email));
        async.elapse(const Duration(seconds: 10));
        expect(cubit.state.resendSecondsRemaining, 20);

        stubForgetPassword(
          const Error<ForgetPasswordEntity>(TooManyRequestsFailure()),
        );
        dispatch(async, ResendOtpEvent(email: email));

        expect(cubit.state.resendSecondsRemaining, 20);
        expect(
          cubit.state.resendOtpState.failure,
          isA<TooManyRequestsFailure>(),
        );
      });
    });

    test('verifying the code does not affect the cooldown', () {
      fakeAsync((async) {
        stubForgetPassword(sentOk());
        dispatch(async, ForgetPasswordEvent(email: email));
        async.elapse(const Duration(seconds: 5));
        expect(cubit.state.resendSecondsRemaining, 25);

        stubVerifyOtp(const Error<VerifyOtpEntity>(BadRequestFailure()));
        dispatch(async, VerifyOtpEvent(otpCode: '000000', email: email));

        expect(cubit.state.resendSecondsRemaining, 25);
        expect(cubit.state.canResendOtp, isFalse);
      });
    });

    test('wrong codes never block resending on the client', () {
      fakeAsync((async) {
        stubVerifyOtp(const Error<VerifyOtpEntity>(BadRequestFailure()));

        for (var i = 0; i < 10; i++) {
          dispatch(async, VerifyOtpEvent(otpCode: '000000', email: email));
        }

        expect(cubit.state.canResendOtp, isTrue);
        expect(cubit.state.otpState.failure, isA<BadRequestFailure>());
        verify(
          () => verifyUserCase.call(email: email, otp: '000000'),
        ).called(10);
      });
    });
  });
}
