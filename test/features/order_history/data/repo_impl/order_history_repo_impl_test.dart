import 'package:driver_app/config/base/base_response.dart' as base;
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_history/data/model/order_history_request_dto.dart';
import 'package:driver_app/features/order_history/data/repo_impl/order_history_repo_impl.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/domain/entities/pagination_entities.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockOrderHistoryRemoteDataSource mockDataSource;
  late OrderHistoryRepoImpl repo;

  setUpAll(() {
    setupFallbackValues();
  });

  setUp(() {
    mockDataSource = MockOrderHistoryRemoteDataSource();
    repo = OrderHistoryRepoImpl(mockDataSource);
  });

  group('getOrders', () {
    test('passes page and pageSize to data source and maps DTO to entities', () async {
      final responseDto = createOrderHistoryResponseDto();
      when(() => mockDataSource.getOrders(any())).thenAnswer(
        (_) async => base.Success(responseDto),
      );

      final result = await repo.getOrders(page: 1, pageSize: 10);

      final captured = verify(() => mockDataSource.getOrders(captureAny())).captured.first as OrderHistoryRequestDto;
      expect(captured.page, 1);
      expect(captured.pageSize, 10);

      expect(result, isA<base.Success<PaginatedEntity<OrderHistoryEntity>>>());
      final data = (result as base.Success<PaginatedEntity<OrderHistoryEntity>>).data;
      expect(data.items.length, 1);
      expect(data.items.first.orderId, 'order123');
    });

    test('passes failures from data source through', () async {
      when(() => mockDataSource.getOrders(any())).thenAnswer(
        (_) async => const base.Error(NotFoundFailure()),
      );

      final result = await repo.getOrders(page: 1, pageSize: 10);

      expect(result, isA<base.Error<PaginatedEntity<OrderHistoryEntity>>>());
      expect((result as base.Error<PaginatedEntity<OrderHistoryEntity>>).failure, isA<NotFoundFailure>());
    });
  });

  group('getOrderDetails', () {
    test('calls getProduct per item and builds details entity', () async {
      final item1 = createOrderDetailsItemDto(productId: 'p1', quantity: 2);
      final item2 = createOrderDetailsItemDto(productId: 'p2', quantity: 1);
      final detailsDto = createOrderDetailsResponseDto(
        status: 'delivered',
        items: [item1, item2],
      );
      final product1 = createProductResponseDto(id: 'p1', price: 100.0);
      final product2 = createProductResponseDto(id: 'p2', price: 50.0);

      when(() => mockDataSource.getOrderDetails('order123')).thenAnswer(
        (_) async => base.Success(detailsDto),
      );
      when(() => mockDataSource.getProduct('p1')).thenAnswer(
        (_) async => base.Success(product1),
      );
      when(() => mockDataSource.getProduct('p2')).thenAnswer(
        (_) async => base.Success(product2),
      );

      final result = await repo.getOrderDetails(orderId: 'order123');

      expect(result, isA<base.Success<OrderHistoryDetailsEntity>>());
      final entity = (result as base.Success<OrderHistoryDetailsEntity>).data;
      expect(entity.orderId, 'order123');
      expect(entity.items.length, 2);
      expect(entity.items[0].productId, 'p1');
      expect(entity.items[0].quantity, 2);
      expect(entity.items[1].productId, 'p2');
      expect(entity.items[1].quantity, 1);
    });

    test('returns that product failure when any getProduct call fails', () async {
      final item1 = createOrderDetailsItemDto(productId: 'p1', quantity: 2);
      final item2 = createOrderDetailsItemDto(productId: 'p2', quantity: 1);
      final detailsDto = createOrderDetailsResponseDto(
        status: 'delivered',
        items: [item1, item2],
      );
      final product1 = createProductResponseDto(id: 'p1');

      when(() => mockDataSource.getOrderDetails('order123')).thenAnswer(
        (_) async => base.Success(detailsDto),
      );
      when(() => mockDataSource.getProduct('p1')).thenAnswer(
        (_) async => base.Success(product1),
      );
      when(() => mockDataSource.getProduct('p2')).thenAnswer(
        (_) async => const base.Error(NotFoundFailure()),
      );

      final result = await repo.getOrderDetails(orderId: 'order123');

      expect(result, isA<base.Error<OrderHistoryDetailsEntity>>());
      final failure = (result as base.Error<OrderHistoryDetailsEntity>).failure;
      expect(failure, isA<NotFoundFailure>());
    });

    test('returns Error(UnexpectedStatusFailure) when order status is non-history (active)', () async {
      final detailsDto = createOrderDetailsResponseDto(
        status: 'pending',
        items: [],
      );
      when(() => mockDataSource.getOrderDetails('order123')).thenAnswer(
        (_) async => base.Success(detailsDto),
      );

      final result = await repo.getOrderDetails(orderId: 'order123');

      expect(result, isA<base.Error<OrderHistoryDetailsEntity>>());
      expect((result as base.Error<OrderHistoryDetailsEntity>).failure, isA<UnexpectedStatusFailure>());
    });

    test('passes data source failure through', () async {
      when(() => mockDataSource.getOrderDetails('order123')).thenAnswer(
        (_) async => const base.Error(TimeoutFailure()),
      );

      final result = await repo.getOrderDetails(orderId: 'order123');

      expect(result, isA<base.Error<OrderHistoryDetailsEntity>>());
      expect((result as base.Error<OrderHistoryDetailsEntity>).failure, isA<TimeoutFailure>());
    });
  });

  group('watchOrderUpdates', () {
    test('returns empty stream', () async {
      final stream = repo.watchOrderUpdates();
      expect(await stream.toList(), isEmpty);
    });
  });
}
