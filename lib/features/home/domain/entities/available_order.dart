import 'package:driver_app/features/home/domain/entities/recipient.dart';
import 'package:driver_app/features/home/domain/entities/store.dart';
import 'package:equatable/equatable.dart';

class AvailableOrder extends Equatable {
  final String orderId;
  final String status;
  final Store store;
  final Recipient recipient;
  final int itemCount;
  final double total;
  final DateTime? estimatedDeliveryAt;
  final DateTime? deliveredAt;
  final DateTime? assignedAt;

  const AvailableOrder({
    required this.orderId,
    required this.status,
    required this.store,
    required this.recipient,
    required this.itemCount,
    required this.total,
    this.estimatedDeliveryAt,
    this.deliveredAt,
    this.assignedAt,
  });

  @override
  String toString() {
    return 'AvailableOrder(orderId: $orderId, status: $status, store: $store, '
        'recipient: $recipient, itemCount: $itemCount, total: $total, '
        'estimatedDeliveryAt: $estimatedDeliveryAt, deliveredAt: $deliveredAt, '
        'assignedAt: $assignedAt)';
  }

  @override
  List<Object?> get props => [
    orderId,
    status,
    store,
    recipient,
    itemCount,
    total,
    estimatedDeliveryAt,
    deliveredAt,
    assignedAt,
  ];
}
