import 'package:dio/dio.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/auth/api/client/auth_api_client.dart';
import 'package:driver_app/features/auth/api/data_source_impl/remote/remote_data_source_impl.dart';
import 'package:driver_app/features/auth/data/model/verify_otp_data_dto.dart';
import 'package:driver_app/features/auth/data/model/request/forget_request/forgot_password_request_dto.dart';
import 'package:driver_app/features/auth/data/model/request/forget_request/reset_password_request_dto.dart';
import 'package:driver_app/features/auth/data/model/request/forget_request/verify_otp_request.dart';
import 'package:driver_app/features/auth/data/model/response/forget_response/forgot_password_response_dto.dart';
import 'package:driver_app/features/auth/data/model/response/forget_response/reset_password_response_dto.dart';
import 'package:driver_app/features/auth/data/model/response/forget_response/verify_otp_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'remote_data_source_impl_test.mocks.dart';
import '../../../../../helpers/mockito_dummies.dart';

@GenerateNiceMocks([MockSpec<AuthApiClient>()])
void main() {
  registerAuthDummies();
  final request = ForgotPasswordRequestDto(email: 'driver@example.com');
  final resetRequest = ResetPasswordRequestDto(
    resetToken: 'token',
    newPassword: 'Passw0rd!',
    confirmPassword: 'Passw0rd!',
  );
  final verifyRequest = VerifyOtpRequest(
    email: 'driver@example.com',
    otp: '123456',
  );

  late MockAuthApiClient apiClient;
  late RemoteDataSourceImpl dataSource;

  DioException dioError({
    required DioExceptionType type,
    int? statusCode,
    Object? body,
  }) {
    final options = RequestOptions(path: '/test');
    return DioException(
      requestOptions: options,
      type: type,
      response: statusCode == null
          ? null
          : Response<dynamic>(
              requestOptions: options,
              statusCode: statusCode,
              data: body,
            ),
    );
  }

  setUp(() {
    apiClient = MockAuthApiClient();
    dataSource = RemoteDataSourceImpl(apiClient);
  });

  group('forgotPassword', () {
    test('returns Success when isSuccess is true', () async {
      final dto = ForgotPasswordResponseDto(
        data: 'sent',
        message: 'ok',
        errorCode: '0',
        isSuccess: true,
      );
      when(apiClient.forgotPassword(any)).thenAnswer((_) async => dto);

      final result = await dataSource.forgotPassword(request);

      expect(result, isA<Success<ForgotPasswordResponseDto>>());
      expect((result as Success<ForgotPasswordResponseDto>).data, dto);
    });

    test('returns ServerFailure carrying the server message', () async {
      when(apiClient.forgotPassword(any)).thenAnswer(
        (_) async => ForgotPasswordResponseDto(
          data: '',
          message: 'Email does not exist',
          errorCode: '404',
          isSuccess: false,
        ),
      );

      final result = await dataSource.forgotPassword(request);

      final failure = (result as Error<ForgotPasswordResponseDto>).failure;
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).serverMessage, 'Email does not exist');
    });

    test('omits the server message when it is blank', () async {
      when(apiClient.forgotPassword(any)).thenAnswer(
        (_) async => ForgotPasswordResponseDto(
          data: '',
          message: '   ',
          errorCode: '400',
          isSuccess: false,
        ),
      );

      final result = await dataSource.forgotPassword(request);

      expect(
        ((result as Error<ForgotPasswordResponseDto>).failure as ServerFailure)
            .serverMessage,
        isNull,
      );
    });

    test('maps a DioException to a typed failure', () async {
      when(apiClient.forgotPassword(any)).thenThrow(
        dioError(type: DioExceptionType.badResponse, statusCode: 404),
      );

      final result = await dataSource.forgotPassword(request);

      expect(
        (result as Error<ForgotPasswordResponseDto>).failure,
        isA<NotFoundFailure>(),
      );
    });

    test('maps a connection error to InternetConnectionFailure', () async {
      when(
        apiClient.forgotPassword(any),
      ).thenThrow(dioError(type: DioExceptionType.connectionError));

      final result = await dataSource.forgotPassword(request);

      expect(
        (result as Error<ForgotPasswordResponseDto>).failure,
        isA<InternetConnectionFailure>(),
      );
    });

    test('swallows any non-Dio error as UnknownFailure', () async {
      when(apiClient.forgotPassword(any)).thenThrow(StateError('boom'));

      final result = await dataSource.forgotPassword(request);

      expect(
        (result as Error<ForgotPasswordResponseDto>).failure,
        isA<UnknownFailure>(),
      );
    });
  });

  group('verifyOtp', () {
    test(
      'returns Success when isSuccess is true and a token is present',
      () async {
        final response = VerifyOtpResponse(
          isSuccess: true,
          errorCode: 0,
          message: 'ok',
          data: VerifyOtpDataDto(resetToken: 'token-abc'),
        );
        when(apiClient.verifyOtp(any)).thenAnswer((_) async => response);

        final result = await dataSource.verifyOtp(
          verifyOtpRequest: verifyRequest,
        );

        expect(result, isA<Success<VerifyOtpResponse>>());
        expect((result as Success<VerifyOtpResponse>).data, response);
      },
    );

    test('returns UnauthorizedFailure when isSuccess is not true', () async {
      when(apiClient.verifyOtp(any)).thenAnswer(
        (_) async => VerifyOtpResponse(
          isSuccess: false,
          errorCode: 400,
          message: 'Invalid code',
        ),
      );

      final result = await dataSource.verifyOtp(
        verifyOtpRequest: verifyRequest,
      );

      final failure = (result as Error<VerifyOtpResponse>).failure;
      expect(failure, isA<UnauthorizedFailure>());
      expect((failure as UnauthorizedFailure).serverMessage, 'Invalid code');
    });

    test(
      'returns ServerFailure when a successful response has no token',
      () async {
        when(apiClient.verifyOtp(any)).thenAnswer(
          (_) async => VerifyOtpResponse(
            isSuccess: true,
            errorCode: 0,
            message: 'ok',
            data: VerifyOtpDataDto(),
          ),
        );

        final result = await dataSource.verifyOtp(
          verifyOtpRequest: verifyRequest,
        );

        expect(
          (result as Error<VerifyOtpResponse>).failure,
          isA<ServerFailure>(),
        );
      },
    );

    test('maps a DioException to a typed failure', () async {
      when(apiClient.verifyOtp(any)).thenThrow(
        dioError(type: DioExceptionType.badResponse, statusCode: 429),
      );

      final result = await dataSource.verifyOtp(
        verifyOtpRequest: verifyRequest,
      );

      expect(
        (result as Error<VerifyOtpResponse>).failure,
        isA<TooManyRequestsFailure>(),
      );
    });
  });

  group('resetPassword', () {
    test('returns Success when isSuccess is true', () async {
      final dto = ResetPasswordResponseDto(
        data: 'ok',
        message: 'changed',
        errorCode: '0',
        isSuccess: true,
      );
      when(apiClient.resetPassword(any)).thenAnswer((_) async => dto);

      final result = await dataSource.resetPassword(resetRequest);

      expect(result, isA<Success<ResetPasswordResponseDto>>());
      expect((result as Success<ResetPasswordResponseDto>).data, dto);
    });

    test('returns UnauthorizedFailure when isSuccess is false', () async {
      when(apiClient.resetPassword(any)).thenAnswer(
        (_) async => ResetPasswordResponseDto(
          data: '',
          message: 'Token expired',
          errorCode: '422',
          isSuccess: false,
        ),
      );

      final result = await dataSource.resetPassword(resetRequest);

      final failure = (result as Error<ResetPasswordResponseDto>).failure;
      expect(failure, isA<UnauthorizedFailure>());
      expect((failure as UnauthorizedFailure).serverMessage, 'Token expired');
    });

    test('maps a DioException to a typed failure', () async {
      when(apiClient.resetPassword(any)).thenThrow(
        dioError(type: DioExceptionType.badResponse, statusCode: 409),
      );

      final result = await dataSource.resetPassword(resetRequest);

      expect(
        (result as Error<ResetPasswordResponseDto>).failure,
        isA<ConflictFailure>(),
      );
    });

    test('swallows any non-Dio error as UnknownFailure', () async {
      when(apiClient.resetPassword(any)).thenThrow(StateError('boom'));

      final result = await dataSource.resetPassword(resetRequest);

      expect(
        (result as Error<ResetPasswordResponseDto>).failure,
        isA<UnknownFailure>(),
      );
    });
  });
}
