import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/verify_oto_entity.dart';
import 'package:driver_app/features/auth/domain/repo/auth_repo.dart';
import 'package:driver_app/features/auth/domain/use_case/verify_otp_user_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'verify_otp_user_case_test.mocks.dart';
import '../../../../helpers/mockito_dummies.dart';

@GenerateNiceMocks([MockSpec<AuthRepo>()])
void main() {
  registerAuthDummies();

  const email = 'driver@example.com';
  const otp = '123456';

  late MockAuthRepo authRepo;
  late VerifyOtpUserCase useCase;

  setUp(() {
    authRepo = MockAuthRepo();
    useCase = VerifyOtpUserCase(authRepo);
  });

  group('VerifyOtpUserCase', () {
    test('returns the reset token when verification succeeds', () async {
      final expires = DateTime(2026, 1, 1);
      final entity = VerifyOtpEntity(
        resetToken: 'token-abc',
        expiresAtUtc: expires,
      );
      when(
        authRepo.verifyOtp(any, any),
      ).thenAnswer((_) async => Success<VerifyOtpEntity>(entity));

      final result = await useCase(email: email, otp: otp);

      expect(result, isA<Success<VerifyOtpEntity>>());
      expect((result as Success<VerifyOtpEntity>).data.resetToken, 'token-abc');
    });

    test('propagates the failure untouched', () async {
      when(authRepo.verifyOtp(any, any)).thenAnswer(
        (_) async => const Error<VerifyOtpEntity>(TooManyRequestsFailure()),
      );

      final result = await useCase(email: email, otp: otp);

      expect(result, isA<Error<dynamic>>());
      expect((result as Error<dynamic>).failure, isA<TooManyRequestsFailure>());
    });

    test('forwards email and otp positionally to the repo', () async {
      when(authRepo.verifyOtp(any, any)).thenAnswer(
        (_) async => Success<VerifyOtpEntity>(
          VerifyOtpEntity(resetToken: 't', expiresAtUtc: DateTime(2026)),
        ),
      );

      await useCase(email: email, otp: otp);

      verify(authRepo.verifyOtp(email, otp)).called(1);
    });
  });
}
