import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';

void main() {
  group('OrdersDataState', () {
    test('countFor returns completedCount or cancelledCount based on status', () {
      const data = OrdersDataState(
        completedCount: 5,
        cancelledCount: 2,
      );

      expect(data.countFor(OrderStatus.completed), 5);
      expect(data.countFor(OrderStatus.cancelled), 2);
    });

    test('copyWith updates properties', () {
      const data = OrdersDataState(completedCount: 1);
      final updated = data.copyWith(completedCount: 3);

      expect(updated.completedCount, 3);
      expect(updated.cancelledCount, 0);
    });

    test('equality works as expected', () {
      const d1 = OrdersDataState(completedCount: 1);
      const d2 = OrdersDataState(completedCount: 1);
      const d3 = OrdersDataState(completedCount: 2);

      expect(d1, equals(d2));
      expect(d1, isNot(equals(d3)));
    });
  });

  group('OrdersState', () {
    final orderCompleted = createOrderHistoryEntity(orderId: '1', status: OrderStatus.completed);
    final orderCancelled = createOrderHistoryEntity(orderId: '2', status: OrderStatus.cancelled);

    test('visibleOrders filters by statusFilter when set', () {
      final state = OrdersState(
        ordersListState: BaseState(
          data: OrdersDataState(orders: [orderCompleted, orderCancelled]),
        ),
      );

      expect(state.visibleOrders, [orderCompleted, orderCancelled]);

      final filteredCompleted = state.withFilter(OrderStatus.completed);
      expect(filteredCompleted.visibleOrders, [orderCompleted]);

      final filteredCancelled = state.withFilter(OrderStatus.cancelled);
      expect(filteredCancelled.visibleOrders, [orderCancelled]);
    });

    test('copyWith keeps or updates properties (failure null if not provided)', () {
      const initial = OrdersState(failure: NotFoundFailure());
      final updated = initial.copyWith(
        ordersListState: const BaseState(isLoading: true),
      );

      expect(updated.ordersListState.isLoading, isTrue);
      expect(updated.failure, isNull);
    });

    test('withFilter preserves failure and ordersListState while updating filter', () {
      const failure = TimeoutFailure();
      const initial = OrdersState(
        failure: failure,
        statusFilter: OrderStatus.completed,
      );

      final next = initial.withFilter(OrderStatus.cancelled);

      expect(next.statusFilter, OrderStatus.cancelled);
      expect(next.failure, failure);
    });

    test('equality works as expected', () {
      const s1 = OrdersState(statusFilter: OrderStatus.completed);
      const s2 = OrdersState(statusFilter: OrderStatus.completed);
      const s3 = OrdersState(statusFilter: OrderStatus.cancelled);

      expect(s1, equals(s2));
      expect(s1, isNot(equals(s3)));
    });
  });
}
