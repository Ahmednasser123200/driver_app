import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';

void main() {
  group('Entities Equatable Equality', () {
    test('OrderStoreEntity equality', () {
      final s1 = createOrderStoreEntity(name: 'A', address: 'B');
      final s2 = createOrderStoreEntity(name: 'A', address: 'B');
      final s3 = createOrderStoreEntity(name: 'Diff', address: 'B');

      expect(s1, equals(s2));
      expect(s1, isNot(equals(s3)));
    });

    test('OrderUserEntity equality', () {
      final u1 = createOrderUserEntity(name: 'A', address: 'B');
      final u2 = createOrderUserEntity(name: 'A', address: 'B');

      expect(u1, equals(u2));
    });

    test('OrderHistoryEntity equality', () {
      final e1 = createOrderHistoryEntity(orderId: '123');
      final e2 = createOrderHistoryEntity(orderId: '123');

      expect(e1, equals(e2));
    });

    test('PaginationEntity and PaginatedEntity equality', () {
      final p1 = createPaginationEntity(page: 1);
      final p2 = createPaginationEntity(page: 1);
      expect(p1, equals(p2));

      final pag1 = createPaginatedEntity<int>(items: [1, 2], pagination: p1);
      final pag2 = createPaginatedEntity<int>(items: [1, 2], pagination: p2);
      expect(pag1, equals(pag2));
    });

    test('OrderProductEntity and OrderItemEntity equality', () {
      final prod1 = createOrderProductEntity(id: 'p1');
      final prod2 = createOrderProductEntity(id: 'p1');
      expect(prod1, equals(prod2));

      final item1 = createOrderItemEntity(productId: 'p1', product: prod1);
      final item2 = createOrderItemEntity(productId: 'p1', product: prod2);
      expect(item1, equals(item2));
    });
  });

  group('OrderHistoryDetailsEntity derived values and props', () {
    test('totalPrice sums price * quantity for all items', () {
      final p1 = createOrderProductEntity(price: 100.0, currency: 'USD');
      final p2 = createOrderProductEntity(price: 50.0, currency: 'USD');
      final item1 = createOrderItemEntity(product: p1, quantity: 2); // 200
      final item2 = createOrderItemEntity(product: p2, quantity: 3); // 150

      final entity = createOrderHistoryDetailsEntity(items: [item1, item2]);

      expect(entity.totalPrice, 350.0);
    });

    test('currency returns first item currency or defaultCurrency when empty', () {
      final p1 = createOrderProductEntity(currency: 'USD');
      final entityWithItems = createOrderHistoryDetailsEntity(
        items: [createOrderItemEntity(product: p1)],
      );
      expect(entityWithItems.currency, 'USD');

      final emptyEntity = createOrderHistoryDetailsEntity(items: []);
      expect(emptyEntity.currency, OrderHistoryDetailsEntity.defaultCurrency);
    });

    test('derived values (totalPrice, currency) are not part of props', () {
      final entity = createOrderHistoryDetailsEntity();
      expect(
        entity.props,
        equals([
          entity.orderId,
          entity.status,
          entity.store,
          entity.user,
          entity.items,
          entity.isCashOnDelivery,
        ]),
      );
    });
  });
}
