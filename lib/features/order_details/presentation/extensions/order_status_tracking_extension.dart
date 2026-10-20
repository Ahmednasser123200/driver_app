
import 'package:driver_app/features/order_details/domain/entities/order_status.dart';

extension OrderStatusTrackingExtension on OrderStatus {
  bool get shouldTrackLocation {
    switch (this) {
      case OrderStatus.pickedUp:
      case OrderStatus.picked:
      case OrderStatus.onTheWay:
      case OrderStatus.outForDelivery:
      case OrderStatus.inProgress:
        return true;

      case OrderStatus.pending:
      case OrderStatus.accepted:
      case OrderStatus.assigned:
      case OrderStatus.arrived:
        return false;
    }
  }
}
