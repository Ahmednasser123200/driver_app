
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/forget_password_entity.dart';
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

  late MockForgetPasswordUserCase forgetUserCase;
  late MockVerifyOtpUserCase verifyUserCase;
  late MockResetPasswordUserCase resetUserCase;
  late ForgetPasswordCubit cubit;

  setUp(() {
    forgetUserCase = MockForgetPasswordUserCase();
    verifyUserCase = MockVerifyOtpUserCase();
    resetUserCase = MockResetPasswordUserCase();
    cubit = ForgetPasswordCubit(
      forgetUserCase,
      verifyUserCase,
      resetUserCase,
    );

    when(
      () => verifyUserCase.call(
        email: any(named: 'email'),
        otp: any(named: 'otp'),
      ),
    ).thenAnswer((_) async => const Error(BadRequestFailure()));
  });

  tearDown(() => cubit.close());

  Future<void> verifyOnce() async {
    await cubit.doEvent(VerifyOtpEvent(otpCode: '000000', email: email));
  }

  group('resend cooldown', () {
    test('starts at 30 seconds when the screen mounts', () {
      expect(cubit.state.resendSecondsRemaining, 0);

      cubit.startResendCooldown();

      expect(
        cubit.state.resendSecondsRemaining,
        OtpPolicy.resendCooldownSeconds,
      );
      expect(cubit.state.canResendOtp, isFalse);
    });

    test('resend becomes available only after the cooldown elapses', () {
      fakeAsync((async) {
        cubit.startResendCooldown();

        async.elapse(const Duration(seconds: 5));
        expect(cubit.state.resendSecondsRemaining, 25);
        expect(cubit.state.canResendOtp, isFalse);

        async.elapse(const Duration(seconds: 25));
        expect(cubit.state.resendSecondsRemaining, 0);
        expect(cubit.state.canResendOtp, isTrue);
      });
    });

    test('a successful resend restarts the cooldown', () async {
      when(() => forgetUserCase.call(email: any(named: 'email'))).thenAnswer(
        (_) async =>
            Success(ForgetPasswordEntity(isSuccess: true, message: 'sent')),
      );

      cubit.startResendCooldown();
      await Future<void>.delayed(const Duration(seconds: 2));
      expect(cubit.state.canResendOtp, isFalse);

      await cubit.doEvent(ResendOtpEvent(email: email));

      expect(
        cubit.state.resendSecondsRemaining,
        OtpPolicy.resendCooldownSeconds,
      );
      expect(cubit.state.canResendOtp, isFalse);
    });
  });
  group('max verify attempts', () {
    test('starts with 5 attempts and is not locked out', () {
      expect(cubit.state.verifyAttemptsRemaining, 5);
      expect(cubit.state.isOtpLockedOut, isFalse);
    });

    test('each failed verification consumes one attempt', () async {
      await verifyOnce();

      expect(cubit.state.verifyAttemptsRemaining, 4);
      expect(cubit.state.isOtpLockedOut, isFalse);
    });

    test('locks out on the 5th failure', () async {
      for (var i = 0; i < 5; i++) {
        await verifyOnce();
      }

      expect(cubit.state.verifyAttemptsRemaining, 0);
      expect(cubit.state.isOtpLockedOut, isTrue);
    });

    test('refuses further verification attempts once locked out', () async {
      for (var i = 0; i < 5; i++) {
        await verifyOnce();
      }
      clearInteractions(verifyUserCase);

      await verifyOnce();

      verifyNever(
        () => verifyUserCase.call(
          email: any(named: 'email'),
          otp: any(named: 'otp'),
        ),
      );
      expect(cubit.state.verifyAttemptsRemaining, 0);
    });

    test('a successful resend restores the full attempt budget', () async {
      for (var i = 0; i < 5; i++) {
        await verifyOnce();
      }
      expect(cubit.state.isOtpLockedOut, isTrue);

      when(() => forgetUserCase.call(email: any(named: 'email'))).thenAnswer(
        (_) async =>
            Success(ForgetPasswordEntity(isSuccess: true, message: 'sent')),
      );
      await cubit.doEvent(ResendOtpEvent(email: email));

      expect(cubit.state.isOtpLockedOut, isFalse);
      expect(cubit.state.verifyAttemptsRemaining, 5);
    });
  });
}
