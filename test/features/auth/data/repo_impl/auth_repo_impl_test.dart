import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/auth/api/service/secure_storage.dart';
import 'package:driver_app/features/auth/data/data_source/remote_data_source/remote_data_source.dart';
import 'package:driver_app/features/auth/data/model/data_dto.dart';
import 'package:driver_app/features/auth/data/model/request/forget_request/forgot_password_request_dto.dart';
import 'package:driver_app/features/auth/data/model/request/forget_request/reset_password_request_dto.dart';
import 'package:driver_app/features/auth/data/model/request/forget_request/verify_otp_request.dart';
import 'package:driver_app/features/auth/data/model/response/forget_response/forgot_password_response_dto.dart';
import 'package:driver_app/features/auth/data/model/response/forget_response/reset_password_response_dto.dart';
import 'package:driver_app/features/auth/data/model/response/forget_response/verify_otp_response.dart';
import 'package:driver_app/features/auth/data/repo_impl/auth_repo_impl.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/forget_password_entity.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/reset_passsword_entity.dart';
import 'package:driver_app/features/auth/domain/entities/forget_entity/verify_oto_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repo_impl_test.mocks.dart';
import '../../../../helpers/mockito_dummies.dart';

@GenerateNiceMocks([
  MockSpec<RemoteDataSource>(),
  MockSpec<SecureStorageService>(),
])
void main() {
  registerAuthDummies();
  const email = 'driver@example.com';
  const otp = '123456';
  const password = 'Passw0rd!';

  late MockRemoteDataSource remoteDataSource;
  late MockSecureStorageService secureStorage;
  late AuthRepoImpl repo;

  setUp(() {
    remoteDataSource = MockRemoteDataSource();
    secureStorage = MockSecureStorageService();
    repo = AuthRepoImpl(remoteDataSource, secureStorage);
  });

  group('forgetPassword', () {
    test('maps a successful DTO to a domain entity', () async {
      final dto = ForgotPasswordResponseDto(
        data: 'sent',
        message: 'Reset link sent',
        errorCode: '0',
        isSuccess: true,
      );
      when(
        remoteDataSource.forgotPassword(any),
      ).thenAnswer((_) async => Success<ForgotPasswordResponseDto>(dto));

      final result = await repo.forgetPassword(email);

      expect(result, isA<Success<ForgetPasswordEntity>>());
      final data = (result as Success<ForgetPasswordEntity>).data;
      expect(data.isSuccess, isTrue);
      expect(data.message, 'Reset link sent');
    });

    test('sends the email in the request DTO', () async {
      when(remoteDataSource.forgotPassword(any)).thenAnswer(
        (_) async => Success<ForgotPasswordResponseDto>(
          ForgotPasswordResponseDto(
            data: '',
            message: 'sent',
            errorCode: '0',
            isSuccess: true,
          ),
        ),
      );

      await repo.forgetPassword(email);

      verify(
        remoteDataSource.forgotPassword(
          argThat(
            isA<ForgotPasswordRequestDto>().having(
              (dto) => dto.email,
              'email',
              email,
            ),
          ),
        ),
      ).called(1);
    });

    test('propagates the failure unchanged', () async {
      when(remoteDataSource.forgotPassword(any)).thenAnswer(
        (_) async => const Error<ForgotPasswordResponseDto>(NotFoundFailure()),
      );

      final result = await repo.forgetPassword(email);

      expect(result, isA<Error<ForgetPasswordEntity>>());
      expect(
        (result as Error<ForgetPasswordEntity>).failure,
        isA<NotFoundFailure>(),
      );
    });
  });

  group('verifyOtp', () {
    VerifyOtpResponse successResponse() => VerifyOtpResponse(
      isSuccess: true,
      errorCode: 0,
      message: 'ok',
      data: Datadto(
        resetToken: 'token-abc',
        expiresAtUtc: DateTime(2026, 1, 1),
      ),
    );

    test('maps the nested data DTO to a domain entity', () async {
      when(
        remoteDataSource.verifyOtp(
          verifyOtpRequest: anyNamed('verifyOtpRequest'),
        ),
      ).thenAnswer((_) async => Success<VerifyOtpResponse>(successResponse()));

      final result = await repo.verifyOtp(email, otp);

      expect(result, isA<Success<VerifyOtpEntity>>());
      expect((result as Success<VerifyOtpEntity>).data.resetToken, 'token-abc');
    });

    test('sends email and otp in the request DTO', () async {
      when(
        remoteDataSource.verifyOtp(
          verifyOtpRequest: anyNamed('verifyOtpRequest'),
        ),
      ).thenAnswer((_) async => Success<VerifyOtpResponse>(successResponse()));

      await repo.verifyOtp(email, otp);

      verify(
        remoteDataSource.verifyOtp(
          verifyOtpRequest: VerifyOtpRequest(email: email, otp: otp),
        ),
      ).called(1);
    });

    test('returns ServerFailure when the response carries no data', () async {
      when(
        remoteDataSource.verifyOtp(
          verifyOtpRequest: anyNamed('verifyOtpRequest'),
        ),
      ).thenAnswer(
        (_) async => Success<VerifyOtpResponse>(
          VerifyOtpResponse(isSuccess: true, errorCode: 0, message: 'ok'),
        ),
      );

      final result = await repo.verifyOtp(email, otp);

      expect(result, isA<Error<VerifyOtpEntity>>());
      expect((result as Error<VerifyOtpEntity>).failure, isA<ServerFailure>());
    });

    test('propagates the failure unchanged', () async {
      when(
        remoteDataSource.verifyOtp(
          verifyOtpRequest: anyNamed('verifyOtpRequest'),
        ),
      ).thenAnswer(
        (_) async => const Error<VerifyOtpResponse>(TooManyRequestsFailure()),
      );

      final result = await repo.verifyOtp(email, otp);

      expect(result, isA<Error<VerifyOtpEntity>>());
      expect(
        (result as Error<VerifyOtpEntity>).failure,
        isA<TooManyRequestsFailure>(),
      );
    });
  });

  group('resetPassword', () {
    test('maps a successful DTO to a domain entity', () async {
      final dto = ResetPasswordResponseDto(
        data: 'ok',
        message: 'Password updated',
        errorCode: '0',
        isSuccess: true,
      );
      when(
        remoteDataSource.resetPassword(any),
      ).thenAnswer((_) async => Success<ResetPasswordResponseDto>(dto));

      final result = await repo.resetPassword(
        email: email,
        otp: otp,
        password: password,
      );

      expect(result, isA<Success<ResetPassswordEntity>>());
      expect(
        (result as Success<ResetPassswordEntity>).data.message,
        'Password updated',
      );
    });

    test('maps the otp onto resetToken and duplicates the password', () async {
      when(remoteDataSource.resetPassword(any)).thenAnswer(
        (_) async => Success<ResetPasswordResponseDto>(
          ResetPasswordResponseDto(
            data: '',
            message: 'ok',
            errorCode: '0',
            isSuccess: true,
          ),
        ),
      );

      await repo.resetPassword(email: email, otp: otp, password: password);

      verify(
        remoteDataSource.resetPassword(
          argThat(
            isA<ResetPasswordRequestDto>()
                .having((dto) => dto.resetToken, 'resetToken', otp)
                .having((dto) => dto.newPassword, 'newPassword', password)
                .having(
                  (dto) => dto.confirmPassword,
                  'confirmPassword',
                  password,
                ),
          ),
        ),
      ).called(1);
    });

    test('propagates the failure unchanged', () async {
      when(remoteDataSource.resetPassword(any)).thenAnswer(
        (_) async => const Error<ResetPasswordResponseDto>(ConflictFailure()),
      );

      final result = await repo.resetPassword(
        email: email,
        otp: otp,
        password: password,
      );

      expect(result, isA<Error<ResetPassswordEntity>>());
      expect(
        (result as Error<ResetPassswordEntity>).failure,
        isA<ConflictFailure>(),
      );
    });
  });

  group('remembered email', () {
    test('loadRememberedEmail delegates to secure storage', () async {
      when(secureStorage.getRememberedEmail()).thenAnswer((_) async => email);

      expect(await repo.loadRememberedEmail(), email);
      verify(secureStorage.getRememberedEmail()).called(1);
    });

    test('loadRememberedEmail returns null when nothing was stored', () async {
      when(secureStorage.getRememberedEmail()).thenAnswer((_) async => null);

      expect(await repo.loadRememberedEmail(), isNull);
    });

    test('saveRememberedEmail delegates to secure storage', () async {
      when(secureStorage.saveRememberedEmail(any)).thenAnswer((_) async {});

      await repo.saveRememberedEmail(email);

      verify(secureStorage.saveRememberedEmail(email)).called(1);
    });

    test('deleteRememberedEmail delegates to secure storage', () async {
      when(secureStorage.deleteRememberedEmail()).thenAnswer((_) async {});

      await repo.deleteRememberedEmail();

      verify(secureStorage.deleteRememberedEmail()).called(1);
    });
  });

  group('unimplemented flows', () {
    test('login throws UnimplementedError', () {
      expect(() => repo.login(const {}), throwsUnimplementedError);
    });

    test('register throws UnimplementedError', () {
      expect(() => repo.register(const {}), throwsUnimplementedError);
    });
  });
}
