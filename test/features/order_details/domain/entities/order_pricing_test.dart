import 'package:driver_app/features/order_details/domain/entities/order_item.dart';
import 'package:driver_app/features/order_details/domain/entities/order_pricing.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('OrderItemEntity.lineTotal', () {
    test('multiplies the unit price by the quantity', () {
      final item = buildOrderItemEntity(quantity: 3, unitPrice: 1500.0);

      expect(item.lineTotal, 4500.0);
    });

    test('is null when the unit price is unknown', () {
      final item = buildOrderItemEntity(unitPrice: null);

      expect(item.lineTotal, isNull);
    });
  });

  group('DriverOrderDetailsEntity.withPricing', () {
    test('fills the total, the currency and the per-item prices', () {
      final entity = buildDriverOrderDetailsEntity(
        totalPrice: null,
        currency: '',
        items: [
          buildOrderItemEntity(productId: 'a', unitPrice: null),
          buildOrderItemEntity(productId: 'b', unitPrice: null),
        ],
      );

      final merged = entity.withPricing(
        const OrderPricingEntity(
          total: 200,
          currency: 'EGP',
          unitPriceByProductId: {'a': 120, 'b': 80},
        ),
      );

      expect(merged.totalPrice, 200.0);
      expect(merged.currency, 'EGP');
      expect(merged.items.first.unitPrice, 120.0);
      expect(merged.items.last.unitPrice, 80.0);
    });

    test('keeps an item price the pricing map does not mention', () {
      const known = OrderItemEntity(
        productId: 'a',
        productName: 'Roses',
        quantity: 1,
        unitPrice: null,
        imageUrl: '',
      );
      const unknown = OrderItemEntity(
        productId: 'b',
        productName: 'Vase',
        quantity: 1,
        unitPrice: null,
        imageUrl: '',
      );
      final entity = buildDriverOrderDetailsEntity(
        totalPrice: null,
        currency: '',
        items: const [known, unknown],
      );

      final merged = entity.withPricing(
        const OrderPricingEntity(total: 120, unitPriceByProductId: {'a': 120}),
      );

      expect(merged.items.first.unitPrice, 120.0);
      expect(merged.items.last, same(unknown));
    });

    test('never overwrites an explicit currency with the pricing one', () {
      final entity = buildDriverOrderDetailsEntity(currency: 'USD');

      final merged = entity.withPricing(
        const OrderPricingEntity(total: 1, currency: 'EGP'),
      );

      expect(merged.currency, 'USD');
    });

    test('keeps every other field untouched', () {
      final entity = buildDriverOrderDetailsEntity(totalPrice: null);

      final merged = entity.withPricing(
        const OrderPricingEntity(total: 10, unitPriceByProductId: {}),
      );

      expect(merged.orderId, entity.orderId);
      expect(merged.orderNumber, entity.orderNumber);
      expect(merged.status, entity.status);
      expect(merged.paymentMethod, entity.paymentMethod);
      expect(merged.notes, entity.notes);
      expect(merged.pickupAddress, entity.pickupAddress);
      expect(merged.userAddress, entity.userAddress);
      expect(merged.recipientInfo, entity.recipientInfo);
      expect(merged.timeline, entity.timeline);
    });

    test('returns the same instance for a null pricing', () {
      final entity = buildDriverOrderDetailsEntity();

      expect(entity.withPricing(null), same(entity));
    });
  });
}
