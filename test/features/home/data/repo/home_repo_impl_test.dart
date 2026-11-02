import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/home/data/dtos/available_orders_response_dto.dart';
import 'package:driver_app/features/home/data/repo/home_repo_impl.dart';
import 'package:driver_app/features/home/domain/entities/available_orders.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../home_test_fixtures.dart';

void main() {
  late MockHomeRemoteDataSource dataSource;
  late HomeRepoImpl repo;

  setUp(() {
    dataSource = MockHomeRemoteDataSource();
    repo = HomeRepoImpl(dataSource);
  });

  group('getAvailableOrders', () {
    test('maps the response DTO to the AvailableOrders entity', () async {
      final dto = AvailableOrdersResponseDto.fromJson(
        buildAvailableOrdersJson(),
      );
      when(
        () => dataSource.getAvailableOrders(page: any(named: 'page')),
      ).thenAnswer((_) async => Success<AvailableOrdersResponseDto>(dto));

      final result = await repo.getAvailableOrders(page: 3);

      expect(result, isA<Success<AvailableOrders>>());
      final orders = (result as Success<AvailableOrders>).data;
      expect(orders.items, hasLength(1));
      expect(orders.items.first.orderId, 'order-1');
      expect(orders.items.first.store.name, 'Flowery Store');
      expect(orders.items.first.recipient.name, 'Nour Mohamed');
      expect(orders.pagination.page, 1);
      verify(() => dataSource.getAvailableOrders(page: 3)).called(1);
    });

    test('propagates the failure when the data source fails', () async {
      when(
        () => dataSource.getAvailableOrders(page: any(named: 'page')),
      ).thenAnswer(
        (_) async => const Error<AvailableOrdersResponseDto>(TimeoutFailure()),
      );

      final result = await repo.getAvailableOrders();

      expect(result, isA<Error<AvailableOrders>>());
      expect((result as Error<AvailableOrders>).failure, isA<TimeoutFailure>());
    });
  });

  group('acceptOrder', () {
    test('returns Success when the data source succeeds', () async {
      when(
        () => dataSource.acceptOrder('order-1'),
      ).thenAnswer((_) async => const Success<void>(null));

      final result = await repo.acceptOrder('order-1');

      expect(result, isA<Success<void>>());
      verify(() => dataSource.acceptOrder('order-1')).called(1);
    });

    test('propagates the failure when the data source fails', () async {
      when(
        () => dataSource.acceptOrder('order-1'),
      ).thenAnswer((_) async => const Error<void>(UnauthorizedFailure()));

      final result = await repo.acceptOrder('order-1');

      expect(result, isA<Error<void>>());
      expect((result as Error<void>).failure, isA<UnauthorizedFailure>());
    });
  });
}
