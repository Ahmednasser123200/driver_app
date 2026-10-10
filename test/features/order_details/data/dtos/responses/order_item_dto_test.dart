import 'package:driver_app/features/order_details/data/dtos/responses/order_item_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fixtures.dart';

void main() {
  Map<String, dynamic> json() => <String, dynamic>{
    'productId': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
    'productName': 'Red Roses Bouquet',
    'quantity': 2,
    'unitPrice': 1500.0,
    'imageUrl': 'https://example.com/rose.png',
  };

  group('fromJson', () {
    test('parses all fields', () {
      final dto = OrderItemDto.fromJson(json());

      expect(dto.productId, '3fa85f64-5717-4562-b3fc-2c963f66afa6');
      expect(dto.productName, 'Red Roses Bouquet');
      expect(dto.quantity, 2);
      expect(dto.unitPrice, 1500.0);
      expect(dto.imageUrl, 'https://example.com/rose.png');
    });

    test('keeps quantity as an int and unitPrice as a double', () {
      final dto = OrderItemDto.fromJson(
        json()
          ..['quantity'] = 7
          ..['unitPrice'] = 99.5,
      );

      expect(dto.quantity, isA<int>());
      expect(dto.quantity, 7);
      expect(dto.unitPrice, isA<double>());
      expect(dto.unitPrice, 99.5);
    });

    test('coerces an integer JSON price into a double', () {
      final dto = OrderItemDto.fromJson(json()..['unitPrice'] = 1500);

      expect(dto.unitPrice, 1500.0);
    });

    test('supports a zero quantity without failing', () {
      expect(OrderItemDto.fromJson(json()..['quantity'] = 0).quantity, 0);
    });
  });

  group('toJson', () {
    test('emits the expected keys', () {
      expect(
        buildOrderItemDto().toJson().keys.toSet(),
        {'productId', 'productName', 'quantity', 'unitPrice', 'imageUrl'},
      );
    });

    test('round-trips through fromJson', () {
      final original = buildOrderItemDto();

      expect(OrderItemDto.fromJson(original.toJson()).toJson(), original.toJson());
    });
  });

  group('toDomain', () {
    test('maps every field onto the entity', () {
      final entity = buildOrderItemDto().toDomain();

      expect(entity.productId, '3fa85f64-5717-4562-b3fc-2c963f66afa6');
      expect(entity.productName, 'Red Roses Bouquet');
      expect(entity.quantity, 2);
      expect(entity.unitPrice, 1500.0);
      expect(entity.imageUrl, 'https://example.com/rose.png');
    });

    test('honours the fixture builder overrides', () {
      final entity = buildOrderItemDto(
        productName: 'White Lilies',
        quantity: 1,
        unitPrice: 250.0,
      ).toDomain();

      expect(entity.productName, 'White Lilies');
      expect(entity.quantity, 1);
      expect(entity.unitPrice, 250.0);
    });
  });
}