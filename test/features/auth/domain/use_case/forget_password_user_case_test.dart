import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/forget_password_entity.dart';
import 'package:driver_app/features/auth/domain/repo/auth_repo.dart';
import 'package:driver_app/features/auth/domain/use_case/forget_password_user_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'forget_password_user_case_test.mocks.dart';
import '../../../../helpers/mockito_dummies.dart';

@GenerateNiceMocks([MockSpec<AuthRepo>()])
void main() {
  registerAuthDummies();

  const email = 'driver@example.com';

  late MockAuthRepo authRepo;
  late ForgetPasswordUserCase useCase;

  setUp(() {
    authRepo = MockAuthRepo();
    useCase = ForgetPasswordUserCase(authRepo);
  });

  group('ForgetPasswordUserCase', () {
    test('returns the entity when the repo succeeds', () async {
      final entity = ForgetPasswordEntity(isSuccess: true, message: 'sent');
      when(
        authRepo.forgetPassword(any),
      ).thenAnswer((_) async => Success<ForgetPasswordEntity>(entity));

      final result = await useCase(email: email);

      expect(result, isA<Success<ForgetPasswordEntity>>());
      expect((result as Success<ForgetPasswordEntity>).data.message, 'sent');
    });

    test('propagates the failure untouched', () async {
      when(authRepo.forgetPassword(any)).thenAnswer(
        (_) async => const Error<ForgetPasswordEntity>(NotFoundFailure()),
      );

      final result = await useCase(email: email);

      expect(result, isA<Error<ForgetPasswordEntity>>());
      expect(
        (result as Error<ForgetPasswordEntity>).failure,
        isA<NotFoundFailure>(),
      );
    });

    test('forwards the email to the repo exactly once', () async {
      when(authRepo.forgetPassword(any)).thenAnswer(
        (_) async => Success<ForgetPasswordEntity>(
          ForgetPasswordEntity(isSuccess: true, message: 'sent'),
        ),
      );

      await useCase(email: email);

      verify(authRepo.forgetPassword(email)).called(1);
    });
  });
}
