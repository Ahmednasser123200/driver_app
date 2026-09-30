import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/reset_passsword_entity.dart';
import 'package:driver_app/features/auth/domain/repo/auth_repo.dart';
import 'package:driver_app/features/auth/domain/use_case/reset_password_user_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'reset_password_user_case_test.mocks.dart';
import '../../../../helpers/mockito_dummies.dart';

@GenerateNiceMocks([MockSpec<AuthRepo>()])
void main() {
  registerAuthDummies();
  const email = 'driver@example.com';
  const otp = 'token-abc';
  const password = 'Passw0rd!';

  late MockAuthRepo authRepo;
  late ResetPasswordUserCase useCase;

  setUp(() {
    authRepo = MockAuthRepo();
    useCase = ResetPasswordUserCase(authRepo);
  });

  group('ResetPasswordUserCase', () {
    test('returns the entity when the reset succeeds', () async {
      final entity = ResetPassswordEntity(isSuccess: true, message: 'changed');
      when(
        authRepo.resetPassword(
          email: anyNamed('email'),
          otp: anyNamed('otp'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => Success<ResetPassswordEntity>(entity));

      final result = await useCase(email: email, otp: otp, password: password);

      expect(result, isA<Success<ResetPassswordEntity>>());
      expect((result as Success<ResetPassswordEntity>).data.message, 'changed');
    });

    test('propagates the failure untouched', () async {
      when(
        authRepo.resetPassword(
          email: anyNamed('email'),
          otp: anyNamed('otp'),
          password: anyNamed('password'),
        ),
      ).thenAnswer(
        (_) async => const Error<ResetPassswordEntity>(ConflictFailure()),
      );

      final result = await useCase(email: email, otp: otp, password: password);

      expect(result, isA<Error<ResetPassswordEntity>>());
      expect(
        (result as Error<ResetPassswordEntity>).failure,
        isA<ConflictFailure>(),
      );
    });

    test('forwards all three named arguments to the repo', () async {
      when(
        authRepo.resetPassword(
          email: anyNamed('email'),
          otp: anyNamed('otp'),
          password: anyNamed('password'),
        ),
      ).thenAnswer(
        (_) async => Success<ResetPassswordEntity>(
          ResetPassswordEntity(isSuccess: true, message: 'ok'),
        ),
      );

      await useCase(email: email, otp: otp, password: password);

      verify(
        authRepo.resetPassword(email: email, otp: otp, password: password),
      ).called(1);
    });
  });
}
