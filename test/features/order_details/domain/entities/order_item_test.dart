import 'package:driver_app/features/order_details/domain/entities/order_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderItemEntity.lineTotal', () {
    test('multiplies the backend unit price by the backend quantity', () {
      const item = OrderItemEntity(
        productId: 'product-id',
        productName: 'Roses',
        quantity: 3,
        unitPrice: 12.5,
        imageUrl: '',
      );

      expect(item.lineTotal, 37.5);
    });

    test('stays unknown if price or quantity is missing', () {
      const missingPrice = OrderItemEntity(
        productId: 'product-id',
        productName: 'Roses',
        quantity: 3,
        unitPrice: null,
        imageUrl: '',
      );
      const missingQuantity = OrderItemEntity(
        productId: 'product-id',
        productName: 'Roses',
        quantity: 0,
        unitPrice: 12.5,
        imageUrl: '',
      );

      expect(missingPrice.lineTotal, isNull);
      expect(missingQuantity.lineTotal, isNull);
    });
  });
}
