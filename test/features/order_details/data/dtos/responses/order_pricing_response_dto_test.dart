import 'package:driver_app/features/order_details/data/dtos/responses/order_pricing_response_dto.dart';
import 'package:driver_app/features/order_details/domain/entities/order_pricing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> envelope() => <String, dynamic>{
    'success': true,
    'message': 'OK',
    'data': <String, dynamic>{
      'subtotal': 100.0,
      'deliveryFee': 35.0,
      'total': 135.0,
      'currency': 'EGP',
      'items': <Map<String, dynamic>>[
        <String, dynamic>{'productId': 'product-a', 'unitPrice': 50.0},
        <String, dynamic>{'productId': 'product-b', 'unitPrice': 50.0},
      ],
    },
    'error': null,
  };

  group('fromJson', () {
    test('unwraps the standard API response envelope', () {
      final dto = OrderPricingDto.fromJson(envelope());

      expect(dto.subtotal, 100.0);
      expect(dto.deliveryFee, 35.0);
      expect(dto.total, 135.0);
      expect(dto.currency, 'EGP');
      expect(dto.items, hasLength(2));
      expect(dto.items!.first.productId, 'product-a');
      expect(dto.items!.first.unitPrice, 50.0);
    });

    test('reads a bare payload without the envelope', () {
      final dto = OrderPricingDto.fromJson(const {
        'total': 99.5,
        'currency': 'EGP',
        'items': [
          {'productId': 'p1', 'unitPrice': 99.5},
        ],
      });

      expect(dto.total, 99.5);
      expect(dto.items!.single.unitPrice, 99.5);
    });

    test('coerces numeric strings and stays null on junk', () {
      final dto = OrderPricingDto.fromJson(const {
        'total': '235',
        'subtotal': 'not-a-number',
        'items': [
          {'productId': 'p1', 'unitPrice': '12.5'},
          {'productId': 'p2'},
          {'unitPrice': 5},
          'not-a-map',
        ],
      });

      expect(dto.total, 235.0);
      expect(dto.subtotal, isNull);
      expect(dto.items, hasLength(3));
      expect(dto.items!.first.unitPrice, 12.5);
      expect(dto.items![1].unitPrice, isNull);
      expect(dto.items![2].productId, isNull);
    });

    test('parses an empty payload instead of throwing', () {
      final dto = OrderPricingDto.fromJson(const {});

      expect(dto.subtotal, isNull);
      expect(dto.total, isNull);
      expect(dto.currency, isNull);
      expect(dto.items, isNull);
    });
  });

  group('toDomain', () {
    test('builds the total and the productId to price map', () {
      final entity = OrderPricingDto.fromJson(envelope()).toDomain();

      expect(entity, isA<OrderPricingEntity>());
      expect(entity.total, 135.0);
      expect(entity.currency, 'EGP');
      expect(entity.unitPriceByProductId, {
        'product-a': 50.0,
        'product-b': 50.0,
      });
    });

    test('skips items without a productId or a price', () {
      final entity = OrderPricingDto.fromJson(const {
        'total': 10.0,
        'items': [
          {'productId': '', 'unitPrice': 5},
          {'productId': 'p-ok', 'unitPrice': null},
          {'productId': 'p-ok', 'unitPrice': 7},
        ],
      }).toDomain();

      expect(entity.unitPriceByProductId, {'p-ok': 7.0});
    });

    test('resolves a missing currency to an empty string', () {
      final entity = OrderPricingDto.fromJson(const {'total': 10.0}).toDomain();

      expect(entity.currency, '');
      expect(entity.unitPriceByProductId, isEmpty);
    });
  });
}
