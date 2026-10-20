import 'package:equatable/equatable.dart';

import 'order_item_entity.dart';
import 'order_status.dart';
import 'order_store_entity.dart';
import 'order_user_entity.dart';

class OrderHistoryDetailsEntity extends Equatable {
  static const String defaultCurrency = 'EGP';

  final String orderId;
  final OrderStatus status;
  final OrderStoreEntity store;
  final OrderUserEntity user;
  final List<OrderItemEntity> items;
  final bool isCashOnDelivery;

  const OrderHistoryDetailsEntity({
    required this.orderId,
    required this.status,
    required this.store,
    required this.user,
    required this.items,
    required this.isCashOnDelivery,
  });

  double get totalPrice {
    return items.fold<double>(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  String get currency {
    return items.isEmpty ? defaultCurrency : items.first.product.currency;
  }

  @override
  List<Object?> get props => [
    orderId,
    status,
    store,
    user,
    items,
    isCashOnDelivery,
  ];
}
