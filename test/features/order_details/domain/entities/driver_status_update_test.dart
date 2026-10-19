import 'package:driver_app/features/order_details/domain/entities/driver_status_update.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('wireValue', () {
    test('uses the exact names the backend binds', () {
      expect(
        DriverStatusUpdate.values.map((status) => status.wireValue).toList(),
        ['PickedUp', 'OutForDelivery', 'AwaitingDeliveryConfirmation'],
      );
    });

    test('follows the driver flow order and never uses snake_case', () {
      for (final status in DriverStatusUpdate.values) {
        expect(status.wireValue, isNot(contains('_')));
        expect(status.wireValue, isNot(contains(' ')));
        expect(status.wireValue[0], status.wireValue[0].toUpperCase());
      }
    });

    test('does not expose Delivered (the customer confirms the delivery)', () {
      expect(
        DriverStatusUpdate.values.map((status) => status.wireValue),
        isNot(contains('Delivered')),
      );
    });
  });
}
