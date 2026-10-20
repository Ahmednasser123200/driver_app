import '../../domain/entities/order_history_entities.dart';

/// Only Delivered (completed) and Cancelled belong to the history.
/// Any other status means the order is still active, so it returns null.
OrderStatus? orderStatusFromApi(String status) {
  switch (status.toLowerCase()) {
    case 'delivered':
      return OrderStatus.completed;
    case 'cancelled':
      return OrderStatus.cancelled;
    default:
      return null;
  }
}
