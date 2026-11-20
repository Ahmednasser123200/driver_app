import 'package:dio/dio.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/home/api/data_source_impl/remote/home_remote_data_source_impl.dart';
import 'package:driver_app/features/home/data/dtos/available_orders_response_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../home_test_fixtures.dart';

void main() {
  late MockHomeApiClient apiClient;
  late HomeRemoteDataSourceImpl dataSource;

  setUp(() {
    apiClient = MockHomeApiClient();
    dataSource = HomeRemoteDataSourceImpl(apiClient);
  });

  group('getAvailableOrders', () {
    test('returns Success with the DTO from the api client', () async {
      final dto = AvailableOrdersResponseDto.fromJson(
        buildAvailableOrdersJson(),
      );
      when(
        () => apiClient.getAvailableOrders(page: any(named: 'page')),
      ).thenAnswer((_) async => dto);

      final result = await dataSource.getAvailableOrders(page: 2);

      expect(result, isA<Success<AvailableOrdersResponseDto>>());
      expect((result as Success<AvailableOrdersResponseDto>).data, same(dto));
      verify(() => apiClient.getAvailableOrders(page: 2)).called(1);
    });

    test('maps DioException to the matching AppFailure', () async {
      when(
        () => apiClient.getAvailableOrders(page: any(named: 'page')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/available-orders'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await dataSource.getAvailableOrders();

      expect(result, isA<Error<AvailableOrdersResponseDto>>());
      expect(
        (result as Error<AvailableOrdersResponseDto>).failure,
        isA<TimeoutFailure>(),
      );
    });

    test('maps a bad response status using the dio failure mapper', () async {
      when(
        () => apiClient.getAvailableOrders(page: any(named: 'page')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/available-orders'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/available-orders'),
            statusCode: 404,
          ),
        ),
      );

      final result = await dataSource.getAvailableOrders();

      expect(
        (result as Error<AvailableOrdersResponseDto>).failure,
        isA<NotFoundFailure>(),
      );
    });

    test('maps unexpected errors to UnknownFailure', () async {
      when(
        () => apiClient.getAvailableOrders(page: any(named: 'page')),
      ).thenAnswer((_) async => throw Exception('boom'));

      final result = await dataSource.getAvailableOrders();

      expect(
        (result as Error<AvailableOrdersResponseDto>).failure,
        isA<UnknownFailure>(),
      );
    });
  });

  group('acceptOrder', () {
    test('returns Success when the api client completes', () async {
      when(() => apiClient.acceptOrder('order-1')).thenAnswer((_) async {});

      final result = await dataSource.acceptOrder('order-1');

      expect(result, isA<Success<void>>());
      verify(() => apiClient.acceptOrder('order-1')).called(1);
    });

    test('maps DioException to the matching AppFailure', () async {
      when(() => apiClient.acceptOrder('order-1')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/accept'),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await dataSource.acceptOrder('order-1');

      expect(result, isA<Error<void>>());
      expect((result as Error<void>).failure, isA<InternetConnectionFailure>());
    });

    test('maps unexpected errors to UnknownFailure', () async {
      when(
        () => apiClient.acceptOrder('order-1'),
      ).thenAnswer((_) async => throw Exception('boom'));

      final result = await dataSource.acceptOrder('order-1');

      expect((result as Error<void>).failure, isA<UnknownFailure>());
    });
  });
}
