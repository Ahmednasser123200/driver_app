import 'package:dio/dio.dart';
import 'package:driver_app/config/dio/dio_failure_mapper.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  RequestOptions buildOptions() => RequestOptions(path: '/orders');

  DioException buildException({
    required DioExceptionType type,
    int? statusCode,
    dynamic data,
  }) {
    return DioException(
      requestOptions: buildOptions(),
      type: type,
      response: statusCode == null
          ? null
          : Response(
              requestOptions: buildOptions(),
              statusCode: statusCode,
              data: data,
            ),
    );
  }

  group('mapDioExceptionToAppFailure - connection level types', () {
    test('maps badCertificate', () {
      final result = mapDioExceptionToAppFailure(
        buildException(type: DioExceptionType.badCertificate),
      );
      expect(result, isA<BadCertificateFailure>());
    });

    test('maps every timeout type to TimeoutFailure', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.transformTimeout,
      ]) {
        expect(
          mapDioExceptionToAppFailure(buildException(type: type)),
          isA<TimeoutFailure>(),
          reason: 'expected $type to map to TimeoutFailure',
        );
      }
    });

    test('maps cancel to CancelFailure', () {
      expect(
        mapDioExceptionToAppFailure(
          buildException(type: DioExceptionType.cancel),
        ),
        isA<CancelFailure>(),
      );
    });

    test('maps connectionError to InternetConnectionFailure', () {
      expect(
        mapDioExceptionToAppFailure(
          buildException(type: DioExceptionType.connectionError),
        ),
        isA<InternetConnectionFailure>(),
      );
    });

    test('maps unknown to UnknownFailure', () {
      expect(
        mapDioExceptionToAppFailure(
          buildException(type: DioExceptionType.unknown),
        ),
        isA<UnknownFailure>(),
      );
    });
  });

  group('mapDioExceptionToAppFailure - HTTP status codes', () {
    test('maps 400 to BadRequestFailure and keeps the server message', () {
      final result = mapDioExceptionToAppFailure(
        buildException(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          data: {'message': 'Invalid order'},
        ),
      );

      expect(result, isA<BadRequestFailure>());
      expect((result as BadRequestFailure).serverMessage, 'Invalid order');
    });

    test('maps 401, 403, 404 and 405 to their dedicated failures', () {
      final expectations = <int, Type>{
        401: UnauthorizedFailure,
        403: ForbiddenFailure,
        404: NotFoundFailure,
        405: MethodNotAllowedFailure,
      };

      expectations.forEach((status, expectedType) {
        final result = mapDioExceptionToAppFailure(
          buildException(
            type: DioExceptionType.badResponse,
            statusCode: status,
          ),
        );
        expect(result.runtimeType, expectedType, reason: 'status $status');
      });
    });

    test('maps 409 to ConflictFailure and keeps the server message', () {
      final result = mapDioExceptionToAppFailure(
        buildException(
          type: DioExceptionType.badResponse,
          statusCode: 409,
          data: {
            'message': 'You already have an active delivery in progress.',
          },
        ),
      );

      expect(result, isA<ConflictFailure>());
      expect(
        (result as ConflictFailure).serverMessage,
        'You already have an active delivery in progress.',
      );
    });

    test('maps 422 to UnprocessableEntityFailure', () {
      final result = mapDioExceptionToAppFailure(
        buildException(
          type: DioExceptionType.badResponse,
          statusCode: 422,
          data: {'message': 'Bad status'},
        ),
      );

      expect(result, isA<UnprocessableEntityFailure>());
      expect(
        (result as UnprocessableEntityFailure).serverMessage,
        'Bad status',
      );
    });

    test('maps 429 to TooManyRequestsFailure', () {
      expect(
        mapDioExceptionToAppFailure(
          buildException(
            type: DioExceptionType.badResponse,
            statusCode: 429,
          ),
        ),
        isA<TooManyRequestsFailure>(),
      );
    });

    test('maps any other status to ServerFailure carrying the status code', () {
      final result = mapDioExceptionToAppFailure(
        buildException(type: DioExceptionType.badResponse, statusCode: 500),
      );

      expect(result, isA<ServerFailure>());
      expect((result as ServerFailure).statusCode, 500);
    });

    test('maps badResponse without a response to ServerFailure(null)', () {
      final result = mapDioExceptionToAppFailure(
        buildException(type: DioExceptionType.badResponse),
      );

      expect(result, isA<ServerFailure>());
      expect((result as ServerFailure).statusCode, isNull);
    });
  });

  group('_extractServerMessage fallbacks', () {
    test('falls back to the error key when message is absent', () {
      final result = mapDioExceptionToAppFailure(
        buildException(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          data: {
            'error': 'Something went wrong',
          },
        ),
      );

      expect((result as BadRequestFailure).serverMessage, 'Something went wrong');
    });

    test('falls back to the detail key when message and error are absent', () {
      final result = mapDioExceptionToAppFailure(
        buildException(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          data: {'detail': 'Detailed reason'},
        ),
      );

      expect(
        (result as BadRequestFailure).serverMessage,
        'Detailed reason',
      );
    });

    test('returns null when the message candidate is not a String', () {
      final result = mapDioExceptionToAppFailure(
        buildException(
          type: DioExceptionType.badResponse,
          statusCode: 409,
          data: {
            'message': null,
            'error': {'code': 'Conflict', 'field': null},
          },
        ),
      );

      expect((result as ConflictFailure).serverMessage, isNull);
    });

    test('returns null when the message is an empty string', () {
      final result = mapDioExceptionToAppFailure(
        buildException(
          type: DioExceptionType.badResponse,
          statusCode: 409,
          data: {'message': ''},
        ),
      );

      expect((result as ConflictFailure).serverMessage, isNull);
    });

    test('returns null when the body is not a Map', () {
      final result = mapDioExceptionToAppFailure(
        buildException(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          data: 'plain text body',
        ),
      );

      expect((result as BadRequestFailure).serverMessage, isNull);
    });
  });
}