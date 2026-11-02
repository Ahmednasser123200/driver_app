import 'package:driver_app/features/home/domain/entities/recipient.dart';
import 'package:driver_app/features/home/domain/entities/store.dart';

class AvailableOrder {
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
}