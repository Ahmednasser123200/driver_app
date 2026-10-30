import 'package:dio/dio.dart';
import 'package:driver_app/config/base/base_response.dart' as base;
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_history/api/data_source_impl/order_history_remote_data_source_impl.dart';
import 'package:driver_app/features/order_history/data/model/order_details_response_dto.dart';
import 'package:driver_app/features/order_history/data/model/order_history_list_response_dto.dart';
import 'package:driver_app/features/order_history/data/model/product_response_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockOrderHistoryApiClient mockClient;
  late OrderHistoryRemoteDataSourceImpl dataSource;

  setUpAll(() {
    setupFallbackValues();
  });

  setUp(() {
    mockClient = MockOrderHistoryApiClient();
    dataSource = OrderHistoryRemoteDataSourceImpl(mockClient);
  });

  group('getOrders', () {
    final request = createOrderHistoryRequestDto();

    test('returns Success when response isOk and has data', () async {
      final dto = createOrderHistoryResponseDto();
      final envelope = createOrderApiResponseDto(success: true, data: dto);
      when(() => mockClient.getOrders(any())).thenAnswer((_) async => envelope);

      final result = await dataSource.getOrders(request);

      expect(result, isA<base.Success<OrderHistoryResponseDto>>());
      expect((result as base.Success<OrderHistoryResponseDto>).data, dto);
    });

    test('returns Error(BadRequestFailure) when isOk is false', () async {
      final envelope = createOrderApiResponseDto<OrderHistoryResponseDto>(
        success: false,
        message: 'Invalid parameters',
      );
      when(() => mockClient.getOrders(any())).thenAnswer((_) async => envelope);

      final result = await dataSource.getOrders(request);

      expect(result, isA<base.Error<OrderHistoryResponseDto>>());
      final failure = (result as base.Error<OrderHistoryResponseDto>).failure;
      expect(failure, isA<BadRequestFailure>());
      expect((failure as BadRequestFailure).serverMessage, 'Invalid parameters');
    });

    test('returns Error(BadRequestFailure) with server message when isOk is true but data is null', () async {
      final envelope = createOrderApiResponseDto<OrderHistoryResponseDto>(
        success: true,
        message: 'Server error msg',
        data: null,
      );
      when(() => mockClient.getOrders(any())).thenAnswer((_) async => envelope);

      final result = await dataSource.getOrders(request);

      expect(result, isA<base.Error<OrderHistoryResponseDto>>());
      final failure = (result as base.Error<OrderHistoryResponseDto>).failure;
      expect(failure, isA<BadRequestFailure>());
      expect((failure as BadRequestFailure).serverMessage, 'Server error msg');
    });

    test('returns Error(BadRequestFailure) with default "No data received" message when message is empty and data is null', () async {
      final envelope = createOrderApiResponseDto<OrderHistoryResponseDto>(
        success: true,
        message: '',
        data: null,
      );
      when(() => mockClient.getOrders(any())).thenAnswer((_) async => envelope);

      final result = await dataSource.getOrders(request);

      expect(result, isA<base.Error<OrderHistoryResponseDto>>());
      final failure = (result as base.Error<OrderHistoryResponseDto>).failure;
      expect(failure, isA<BadRequestFailure>());
      expect((failure as BadRequestFailure).serverMessage, 'No data received');
    });

    test('returns matching AppFailure on DioException', () async {
      final dioError = DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      );
      when(() => mockClient.getOrders(any())).thenThrow(dioError);

      final result = await dataSource.getOrders(request);

      expect(result, isA<base.Error<OrderHistoryResponseDto>>());
      final failure = (result as base.Error<OrderHistoryResponseDto>).failure;
      expect(failure, isA<TimeoutFailure>());
    });

    test('returns Error(UnknownFailure) on non-DioException exception', () async {
      when(() => mockClient.getOrders(any())).thenThrow(Exception('Unexpected'));

      final result = await dataSource.getOrders(request);

      expect(result, isA<base.Error<OrderHistoryResponseDto>>());
      final failure = (result as base.Error<OrderHistoryResponseDto>).failure;
      expect(failure, isA<UnknownFailure>());
    });
  });

  group('getOrderDetails', () {
    test('returns Success when response isOk and has data', () async {
      final dto = createOrderDetailsResponseDto();
      final envelope = createOrderApiResponseDto(success: true, data: dto);
      when(() => mockClient.getOrderDetails(any())).thenAnswer((_) async => envelope);

      final result = await dataSource.getOrderDetails('order123');

      expect(result, isA<base.Success<OrderDetailsResponseDto>>());
      expect((result as base.Success<OrderDetailsResponseDto>).data, dto);
    });

    test('returns Error(NotFoundFailure) on 404 DioException', () async {
      final dioError = DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
        ),
        type: DioExceptionType.badResponse,
      );
      when(() => mockClient.getOrderDetails(any())).thenThrow(dioError);

      final result = await dataSource.getOrderDetails('order123');

      expect(result, isA<base.Error<OrderDetailsResponseDto>>());
      final failure = (result as base.Error<OrderDetailsResponseDto>).failure;
      expect(failure, isA<NotFoundFailure>());
    });
  });

  group('getProduct', () {
    test('returns Success when catalog response isSuccess and has data', () async {
      final dto = createProductResponseDto();
      final envelope = createCatalogApiResponseDto(isSuccess: true, data: dto);
      when(() => mockClient.getProduct(any())).thenAnswer((_) async => envelope);

      final result = await dataSource.getProduct('p1');

      expect(result, isA<base.Success<ProductResponseDto>>());
      expect((result as base.Success<ProductResponseDto>).data, dto);
    });

    test('returns Error(BadRequestFailure) when isSuccess is false', () async {
      final envelope = createCatalogApiResponseDto<ProductResponseDto>(
        isSuccess: false,
        message: 'Product not found',
      );
      when(() => mockClient.getProduct(any())).thenAnswer((_) async => envelope);

      final result = await dataSource.getProduct('p1');

      expect(result, isA<base.Error<ProductResponseDto>>());
      final failure = (result as base.Error<ProductResponseDto>).failure;
      expect(failure, isA<BadRequestFailure>());
      expect((failure as BadRequestFailure).serverMessage, 'Product not found');
    });
  });
}
