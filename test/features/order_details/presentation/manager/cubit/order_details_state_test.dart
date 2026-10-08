import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fixtures.dart';

void main() {
  group('defaults', () {
    test('a fresh state has three idle slices', () {
      const state = OrderDetailsState();

      expect(state.orderDetails.isLoading, isFalse);
      expect(state.orderDetails.errorMessage, '');
      expect(state.orderDetails.data, isNull);

      expect(state.updateOrderStatus.isLoading, isFalse);
      expect(state.updateOrderStatus.errorMessage, '');
      expect(state.updateOrderStatus.data, isNull);

      expect(state.reportDriverLocation.isLoading, isFalse);
      expect(state.reportDriverLocation.errorMessage, '');
      expect(state.reportDriverLocation.data, isNull);
    });
  });

  group('copyWith', () {
    test('returns a new instance rather than mutating', () {
      const original = OrderDetailsState();

      final updated = original.copyWith(
        orderDetails: const BaseState(isLoading: true),
      );

      expect(identical(updated, original), isFalse);
      expect(original.orderDetails.isLoading, isFalse);
      expect(updated.orderDetails.isLoading, isTrue);
    });

    test('changes only the supplied slice', () {
      final state = OrderDetailsState(
        orderDetails: BaseState(
          isLoading: true,
          data: buildDriverOrderDetailsEntity(),
        ),
        updateOrderStatus: const BaseState(isLoading: true),
        reportDriverLocation: const BaseState(isLoading: true),
      );

      final updated = state.copyWith(
        orderDetails: const BaseState(isLoading: false),
      );

      expect(updated.orderDetails.isLoading, isFalse);
      expect(updated.updateOrderStatus.isLoading, isTrue);
      expect(updated.reportDriverLocation.isLoading, isTrue);
    });

    test('keeps the other slices identical', () {
      final state = OrderDetailsState(
        updateOrderStatus: const BaseState(isLoading: true),
      );

      final updated = state.copyWith(
        orderDetails: const BaseState(isLoading: true),
      );

      expect(identical(updated.updateOrderStatus, state.updateOrderStatus),
          isTrue);
    });

    test('cannot clear a slice with null', () {
      final state = OrderDetailsState(
        updateOrderStatus: const BaseState(isLoading: true),
      );

      expect(
        state.copyWith(updateOrderStatus: null).updateOrderStatus.isLoading,
        isTrue,
      );
    });

    test('round-trips a full replacement', () {
      final state = OrderDetailsState(
        orderDetails: BaseState(
          isLoading: false,
          data: buildDriverOrderDetailsEntity(),
        ),
      );

      expect(
        state.copyWith(orderDetails: state.orderDetails).orderDetails,
        same(state.orderDetails),
      );
    });
  });

  group('equality', () {
    test('two default states are equal', () {
      expect(const OrderDetailsState(), const OrderDetailsState());
    });

    test('states differing in any slice are not equal', () {
      expect(
        const OrderDetailsState(
          orderDetails: BaseState(isLoading: true),
        ),
        isNot(const OrderDetailsState()),
      );
      expect(
        const OrderDetailsState(
          updateOrderStatus: BaseState(isLoading: true),
        ),
        isNot(const OrderDetailsState()),
      );
      expect(
        const OrderDetailsState(
          reportDriverLocation: BaseState(isLoading: true),
        ),
        isNot(const OrderDetailsState()),
      );
    });

    test('states wrapping the identical entity instance are equal', () {
      final entity = buildDriverOrderDetailsEntity();

      expect(
        OrderDetailsState(
          orderDetails: BaseState(data: entity),
        ),
        OrderDetailsState(
          orderDetails: BaseState(data: entity),
        ),
      );
    });

    test('structurally identical but distinct entities are not equal', () {
      expect(
        OrderDetailsState(
          orderDetails: BaseState(data: buildDriverOrderDetailsEntity()),
        ),
        isNot(
          OrderDetailsState(
            orderDetails: BaseState(data: buildDriverOrderDetailsEntity()),
          ),
        ),
      );
    });
  });
}