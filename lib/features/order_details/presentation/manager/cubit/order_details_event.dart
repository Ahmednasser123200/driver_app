sealed class OrderDetailsEvent {}

class GetDriverOrderDetailsEvent extends OrderDetailsEvent {
  final String orderId;

  GetDriverOrderDetailsEvent({required this.orderId});
}


class UpdateOrderStatusEvent extends OrderDetailsEvent {
  final String orderId;
  final String newStatus;

  UpdateOrderStatusEvent({required this.orderId, required this.newStatus});
}
