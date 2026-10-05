import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fixtures.dart';

void main() {
  group('defaults', () {
    test('a fresh state is idle and empty', () {
      const state = OrderDetailsState();

      expect(state.isLoading, isFalse);
      expect(state.errorMessage, '');
      expect(state.data, isNull);
      expect(state.updateStatusSuccess, isFalse);
      expect(state.reportLocationSuccess, isFalse);
    });
  });

  group('copyWith', () {
    test('returns a new instance rather than mutating', () {
      const original = OrderDetailsState();

      final updated = original.copyWith(isLoading: true);

      expect(identical(updated, original), isFalse);
      expect(original.isLoading, isFalse);
      expect(updated.isLoading, isTrue);
    });

    test('changes only the supplied fields', () {
      final state = OrderDetailsState(
        isLoading: true,
        errorMessage: 'boom',
        data: buildDriverOrderDetailsEntity(),
        updateStatusSuccess: true,
        reportLocationSuccess: true,
      );

      final updated = state.copyWith(isLoading: false);

      expect(updated.isLoading, isFalse);
      expect(updated.errorMessage, 'boom');
      expect(updated.data, same(state.data));
      expect(updated.updateStatusSuccess, isTrue);
      expect(updated.reportLocationSuccess, isTrue);
    });

    test('can reset a string field back to empty', () {
      final state = OrderDetailsState(errorMessage: 'boom');

      expect(state.copyWith(errorMessage: '').errorMessage, '');
    });

    test('can flip the success booleans back to false', () {
      final state = OrderDetailsState(
        updateStatusSuccess: true,
        reportLocationSuccess: true,
      );

      final updated = state.copyWith(
        updateStatusSuccess: false,
        reportLocationSuccess: false,
      );

      expect(updated.updateStatusSuccess, isFalse);
      expect(updated.reportLocationSuccess, isFalse);
    });

    test('keeps the existing data when data is not supplied', () {
      final entity = buildDriverOrderDetailsEntity();
      final state = OrderDetailsState(data: entity);

      expect(state.copyWith(isLoading: true).data, same(entity));
    });

    test('cannot clear data because null means "keep the old value"', () {
      final entity = buildDriverOrderDetailsEntity();
      final state = OrderDetailsState(data: entity);

      expect(state.copyWith(data: null).data, same(entity));
    });
  });

  group('equality', () {
    test('two default states are equal', () {
      expect(const OrderDetailsState(), const OrderDetailsState());
    });

    test('states differing in any flag are not equal', () {
      expect(
        const OrderDetailsState(isLoading: true),
        isNot(const OrderDetailsState()),
      );
      expect(
        const OrderDetailsState(updateStatusSuccess: true),
        isNot(const OrderDetailsState()),
      );
      expect(
        const OrderDetailsState(reportLocationSuccess: true),
        isNot(const OrderDetailsState()),
      );
      expect(
        const OrderDetailsState(errorMessage: 'x'),
        isNot(const OrderDetailsState()),
      );
    });

    test('states wrapping the identical entity instance are equal', () {
      final entity = buildDriverOrderDetailsEntity();

      expect(
        OrderDetailsState(data: entity),
        OrderDetailsState(data: entity),
      );
    });

    test('structurally identical but distinct entities are not equal', () {
      expect(
        OrderDetailsState(data: buildDriverOrderDetailsEntity()),
        isNot(OrderDetailsState(data: buildDriverOrderDetailsEntity())),
      );
    });
  });
}