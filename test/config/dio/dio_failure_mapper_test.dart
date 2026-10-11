import 'package:dio/dio.dart';
import 'package:driver_app/config/dio/dio_failure_mapper.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DioException error(DioExceptionType type, {int? statusCode, Object? body}) {
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

  group('transport level errors', () {
    test('connectionError maps to InternetConnectionFailure', () {
      expect(
        mapDioExceptionToAppFailure(error(DioExceptionType.connectionError)),
        isA<InternetConnectionFailure>(),
      );
    });

    test('connectionTimeout maps to TimeoutFailure', () {
      expect(
        mapDioExceptionToAppFailure(error(DioExceptionType.connectionTimeout)),
        isA<TimeoutFailure>(),
      );
    });

    test('sendTimeout maps to TimeoutFailure', () {
      expect(
        mapDioExceptionToAppFailure(error(DioExceptionType.sendTimeout)),
        isA<TimeoutFailure>(),
      );
    });

    test('receiveTimeout maps to TimeoutFailure', () {
      expect(
        mapDioExceptionToAppFailure(error(DioExceptionType.receiveTimeout)),
        isA<TimeoutFailure>(),
      );
    });

    test('transformTimeout maps to TimeoutFailure', () {
      expect(
        mapDioExceptionToAppFailure(error(DioExceptionType.transformTimeout)),
        isA<TimeoutFailure>(),
      );
    });

    test('cancel maps to CancelFailure', () {
      expect(
        mapDioExceptionToAppFailure(error(DioExceptionType.cancel)),
        isA<CancelFailure>(),
      );
    });

    test('badCertificate maps to BadCertificateFailure', () {
      expect(
        mapDioExceptionToAppFailure(error(DioExceptionType.badCertificate)),
        isA<BadCertificateFailure>(),
      );
    });

    test('unknown maps to UnknownFailure', () {
      expect(
        mapDioExceptionToAppFailure(error(DioExceptionType.unknown)),
        isA<UnknownFailure>(),
      );
    });
  });

  group('badResponse status codes', () {
    test('400 maps to BadRequestFailure', () {
      expect(
        mapDioExceptionToAppFailure(
          error(DioExceptionType.badResponse, statusCode: 400),
        ),
        isA<BadRequestFailure>(),
      );
    });

    test('401 maps to UnauthorizedFailure', () {
      expect(
        mapDioExceptionToAppFailure(
          error(DioExceptionType.badResponse, statusCode: 401),
        ),
        isA<UnauthorizedFailure>(),
      );
    });

    test('403 maps to ForbiddenFailure', () {
      expect(
        mapDioExceptionToAppFailure(
          error(DioExceptionType.badResponse, statusCode: 403),
        ),
        isA<ForbiddenFailure>(),
      );
    });

    test('404 maps to NotFoundFailure', () {
      expect(
        mapDioExceptionToAppFailure(
          error(DioExceptionType.badResponse, statusCode: 404),
        ),
        isA<NotFoundFailure>(),
      );
    });

    test('405 maps to MethodNotAllowedFailure', () {
      expect(
        mapDioExceptionToAppFailure(
          error(DioExceptionType.badResponse, statusCode: 405),
        ),
        isA<MethodNotAllowedFailure>(),
      );
    });

    test('409 maps to ConflictFailure', () {
      expect(
        mapDioExceptionToAppFailure(
          error(DioExceptionType.badResponse, statusCode: 409),
        ),
        isA<ConflictFailure>(),
      );
    });

    test('422 maps to UnprocessableEntityFailure', () {
      expect(
        mapDioExceptionToAppFailure(
          error(DioExceptionType.badResponse, statusCode: 422),
        ),
        isA<UnprocessableEntityFailure>(),
      );
    });

    test('429 maps to TooManyRequestsFailure', () {
      expect(
        mapDioExceptionToAppFailure(
          error(DioExceptionType.badResponse, statusCode: 429),
        ),
        isA<TooManyRequestsFailure>(),
      );
    });

    test('an unmapped status code falls back to ServerFailure', () {
      expect(
        mapDioExceptionToAppFailure(
          error(DioExceptionType.badResponse, statusCode: 503),
        ),
        isA<ServerFailure>(),
      );
    });
  });

  group('server message extraction', () {
    test('reads "message" from a map body', () {
      final failure = mapDioExceptionToAppFailure(
        error(
          DioExceptionType.badResponse,
          statusCode: 400,
          body: {'message': 'Email already in use'},
        ),
      );

      expect(
        (failure as BadRequestFailure).serverMessage,
        'Email already in use',
      );
    });

    test('falls back to "error" then "detail"', () {
      expect(
        (mapDioExceptionToAppFailure(
                  error(
                    DioExceptionType.badResponse,
                    statusCode: 400,
                    body: {'error': 'bad otp'},
                  ),
                )
                as BadRequestFailure)
            .serverMessage,
        'bad otp',
      );
      expect(
        (mapDioExceptionToAppFailure(
                  error(
                    DioExceptionType.badResponse,
                    statusCode: 400,
                    body: {'detail': 'too many attempts'},
                  ),
                )
                as BadRequestFailure)
            .serverMessage,
        'too many attempts',
      );
    });

    test('returns null when the body carries no known key', () {
      expect(
        (mapDioExceptionToAppFailure(
                  error(
                    DioExceptionType.badResponse,
                    statusCode: 400,
                    body: {'unrelated': 'value'},
                  ),
                )
                as BadRequestFailure)
            .serverMessage,
        isNull,
      );
    });

    test('ignores a non-string message value', () {
      expect(
        (mapDioExceptionToAppFailure(
                  error(
                    DioExceptionType.badResponse,
                    statusCode: 400,
                    body: {'message': 42},
                  ),
                )
                as BadRequestFailure)
            .serverMessage,
        isNull,
      );
    });
  });
}
