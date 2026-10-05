import 'package:driver_app/features/order_details/data/dtos/responses/update_order_status_response_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fixtures.dart';

void main() {
  Map<String, dynamic> json() => <String, dynamic>{
    'orderId': kOrderId,
    'status': 'PickedUp',
    'updatedAt': '2026-09-19T18:00:00Z',
  };

  group('fromJson', () {
    test('parses all fields', () {
      final dto = UpdateOrderStatusResponseDto.fromJson(json());

      expect(dto.orderId, kOrderId);
      expect(dto.status, 'PickedUp');
      expect(dto.updatedAt, '2026-09-19T18:00:00Z');
    });

    test('parses each documented backend status verbatim', () {
      for (final status in [
        'PickedUp',
        'OutForDelivery',
        'AwaitingDeliveryConfirmation',
      ]) {
        expect(
          UpdateOrderStatusResponseDto.fromJson(
            json()..['status'] = status,
          ).status,
          status,
        );
      }
    });
  });

  group('toJson', () {
    test('emits the expected keys', () {
      expect(
        buildUpdateOrderStatusResponseDto().toJson().keys.toSet(),
        {'orderId', 'status', 'updatedAt'},
      );
    });

    test('round-trips through fromJson', () {
      final original = buildUpdateOrderStatusResponseDto();

      expect(
        UpdateOrderStatusResponseDto.fromJson(original.toJson()).toJson(),
        original.toJson(),
      );
    });
  });

  group('toDomain', () {
    test('maps every field onto the entity', () {
      final entity = buildUpdateOrderStatusResponseDto().toDomain();

      expect(entity.orderId, kOrderId);
      expect(entity.status, 'PickedUp');
      expect(entity.updatedAt, '2026-09-19T18:00:00Z');
    });
  });
}