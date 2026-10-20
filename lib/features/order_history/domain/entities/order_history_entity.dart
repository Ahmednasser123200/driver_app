import 'package:equatable/equatable.dart';

import 'order_status.dart';
import 'order_store_entity.dart';
import 'order_user_entity.dart';

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
