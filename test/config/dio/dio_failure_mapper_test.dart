import 'package:dio/dio.dart';
import 'package:driver_app/config/dio/dio_failure_mapper.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DioException exception({
    required DioExceptionType type,
    int? statusCode,
    Object? data,
  }) {
    final options = RequestOptions(path: '/orders');
    return DioException(
      requestOptions: options,
      type: type,
      response: statusCode == null
          ? null
          : Response<dynamic>(
              requestOptions: options,
              statusCode: statusCode,
              data: data,
            ),
    );
  }

  group('transport errors', () {
    test('maps connection errors', () {
      expect(
        mapDioExceptionToAppFailure(
          exception(type: DioExceptionType.connectionError),
        ),
        isA<InternetConnectionFailure>(),
      );
    });

    test('maps all timeout types', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.transformTimeout,
      ]) {
        expect(
          mapDioExceptionToAppFailure(exception(type: type)),
          isA<TimeoutFailure>(),
          reason: '$type',
        );
      }
    });

    test('maps cancel, certificate, and unknown errors', () {
      expect(
        mapDioExceptionToAppFailure(exception(type: DioExceptionType.cancel)),
        isA<CancelFailure>(),
      );
      expect(
        mapDioExceptionToAppFailure(
          exception(type: DioExceptionType.badCertificate),
        ),
        isA<BadCertificateFailure>(),
      );
      expect(
        mapDioExceptionToAppFailure(exception(type: DioExceptionType.unknown)),
        isA<UnknownFailure>(),
      );
    });
  });

  group('HTTP responses', () {
    test('maps 400 and preserves the message', () {
      final result = mapDioExceptionToAppFailure(
        exception(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          data: {'message': 'Invalid order'},
        ),
      );

      expect(result, isA<BadRequestFailure>());
      expect((result as BadRequestFailure).serverMessage, 'Invalid order');
    });

    test('maps 401, 403, 404, and 405', () {
      final expected = <int, Type>{
        401: UnauthorizedFailure,
        403: ForbiddenFailure,
        404: NotFoundFailure,
        405: MethodNotAllowedFailure,
      };

      for (final entry in expected.entries) {
        final result = mapDioExceptionToAppFailure(
          exception(type: DioExceptionType.badResponse, statusCode: entry.key),
        );
        expect(result.runtimeType, entry.value, reason: '${entry.key}');
      }
    });

    test('maps conflict and validation responses with server messages', () {
      final conflict = mapDioExceptionToAppFailure(
        exception(
          type: DioExceptionType.badResponse,
          statusCode: 409,
          data: {'message': 'Already delivering'},
        ),
      );
      final invalid = mapDioExceptionToAppFailure(
        exception(
          type: DioExceptionType.badResponse,
          statusCode: 422,
          data: {'message': 'Invalid status'},
        ),
      );

      expect((conflict as ConflictFailure).serverMessage, 'Already delivering');
      expect(
        (invalid as UnprocessableEntityFailure).serverMessage,
        'Invalid status',
      );
    });

    test('maps 429 and server errors', () {
      expect(
        mapDioExceptionToAppFailure(
          exception(type: DioExceptionType.badResponse, statusCode: 429),
        ),
        isA<TooManyRequestsFailure>(),
      );

      final result = mapDioExceptionToAppFailure(
        exception(type: DioExceptionType.badResponse, statusCode: 500),
      );
      expect((result as ServerFailure).statusCode, 500);
    });

    test('maps a response without a status code to ServerFailure', () {
      final result = mapDioExceptionToAppFailure(
        exception(type: DioExceptionType.badResponse),
      );
      expect((result as ServerFailure).statusCode, isNull);
    });
  });

  group('server message extraction', () {
    test('uses error and detail when message is absent', () {
      final error = mapDioExceptionToAppFailure(
        exception(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          data: {'error': 'Error message'},
        ),
      );
      final detail = mapDioExceptionToAppFailure(
        exception(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          data: {'detail': 'Detailed message'},
        ),
      );

      expect((error as BadRequestFailure).serverMessage, 'Error message');
      expect((detail as BadRequestFailure).serverMessage, 'Detailed message');
    });

    test('ignores non-string, empty, and non-map response bodies', () {
      for (final data in [
        {
          'message': null,
          'error': <String, Object>{'code': 'Conflict'},
        },
        {'message': ''},
        'plain text',
      ]) {
        final result = mapDioExceptionToAppFailure(
          exception(
            type: DioExceptionType.badResponse,
            statusCode: 400,
            data: data,
          ),
        );
        expect((result as BadRequestFailure).serverMessage, isNull);
      }
    });
  });
}
