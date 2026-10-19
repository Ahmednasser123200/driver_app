import 'package:driver_app/features/home/data/dtos/active_order_id_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActiveOrderIdDto.fromJson', () {
    test('unwraps the standard API response envelope', () {
      final dto = ActiveOrderIdDto.fromJson(const {
        'success': true,
        'message': 'OK',
        'data': {'orderId': 'order-9'},
        'error': null,
      });

      expect(dto.orderId, 'order-9');
    });

    test('reads a bare payload without the envelope', () {
      final dto = ActiveOrderIdDto.fromJson(const {'orderId': 'order-9'});

      expect(dto.orderId, 'order-9');
    });

    test('trims surrounding whitespace', () {
      final dto = ActiveOrderIdDto.fromJson(const {'orderId': '  order-9  '});

      expect(dto.orderId, 'order-9');
    });

    test('resolves a missing orderId to no active order', () {
      final dto = ActiveOrderIdDto.fromJson(const {});

      expect(dto.orderId, isEmpty);
    });

    test('resolves a null orderId to no active order', () {
      final dto = ActiveOrderIdDto.fromJson(const {
        'data': {'orderId': null},
      });

      expect(dto.orderId, isEmpty);
    });

    test('resolves a blank orderId to no active order', () {
      final dto = ActiveOrderIdDto.fromJson(const {'orderId': '   '});

      expect(dto.orderId, isEmpty);
    });

    test('resolves a non-string orderId to no active order', () {
      final dto = ActiveOrderIdDto.fromJson(const {'orderId': 42});

      expect(dto.orderId, isEmpty);
    });

    test('resolves an empty data object to no active order', () {
      final dto = ActiveOrderIdDto.fromJson(const {
        'data': <String, dynamic>{},
      });

      expect(dto.orderId, isEmpty);
    });
  });
}
