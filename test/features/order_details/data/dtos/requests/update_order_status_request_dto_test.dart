import 'package:driver_app/features/order_details/data/dtos/requests/update_order_status_request_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toJson', () {
    test('serialises only the newStatus field', () {
      final json = UpdateOrderStatusRequestDto(newStatus: 'PickedUp').toJson();

      expect(json, {'newStatus': 'PickedUp'});
    });

    test('does not send the orderId as part of the body', () {
      final json = UpdateOrderStatusRequestDto(newStatus: 'PickedUp').toJson();

      expect(json.containsKey('orderId'), isFalse);
    });
  });

  group('fromJson', () {
    test('parses the newStatus field', () {
      expect(
        UpdateOrderStatusRequestDto.fromJson({'newStatus': 'OutForDelivery'})
            .newStatus,
        'OutForDelivery',
      );
    });

    test('round-trips through toJson', () {
      final original = UpdateOrderStatusRequestDto(newStatus: 'PickedUp');

      expect(
        UpdateOrderStatusRequestDto.fromJson(original.toJson()).newStatus,
        original.newStatus,
      );
    });
  });

  group('status passthrough', () {
    test('keeps each documented backend status verbatim', () {
      for (final status in [
        'PickedUp',
        'OutForDelivery',
        'AwaitingDeliveryConfirmation',
      ]) {
        expect(
          UpdateOrderStatusRequestDto(newStatus: status).toJson(),
          {'newStatus': status},
        );
      }
    });
  });
}