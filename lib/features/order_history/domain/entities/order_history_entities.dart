import 'package:equatable/equatable.dart';

enum OrderStatus { completed, cancelled }

class OrderStoreEntity extends Equatable {
  final String name;
  final String address;
  final String? imageUrl;

  const OrderStoreEntity({
    required this.name,
    required this.address,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, address, imageUrl];
}

class OrderUserEntity extends Equatable {
  final String name;
  final String address;
  final String? imageUrl;

  const OrderUserEntity({
    required this.name,
    required this.address,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, address, imageUrl];
}

class OrderProductEntity extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String currency;
  final double price;

  const OrderProductEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.currency,
    required this.price,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, currency, price];
}

class OrderItemEntity extends Equatable {
  final String productId;
  final int quantity;
  final OrderProductEntity product;

  const OrderItemEntity({
    required this.productId,
    required this.quantity,
    required this.product,
  });

  @override
  List<Object?> get props => [productId, quantity, product];
}

class OrderHistoryEntity extends Equatable {
  final String orderId;
  final OrderStatus status;
  final OrderStoreEntity store;
  final OrderUserEntity user;
  final int itemCount;
  final double total;
  final DateTime assignedAt;
  final DateTime? estimatedDeliveryAt;
  final DateTime? deliveredAt;

  const OrderHistoryEntity({
    required this.orderId,
    required this.status,
    required this.store,
    required this.user,
    required this.itemCount,
    required this.total,
    required this.assignedAt,
    this.estimatedDeliveryAt,
    this.deliveredAt,
  });

  @override
  List<Object?> get props => [
    orderId,
    status,
    store,
    user,
    itemCount,
    total,
    assignedAt,
    estimatedDeliveryAt,
    deliveredAt,
  ];
}

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
