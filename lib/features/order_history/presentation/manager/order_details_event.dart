sealed class OrderDetailsEvent {}

class GetOrderDetailsEvent extends OrderDetailsEvent {
  final String orderId;
  GetOrderDetailsEvent({required this.orderId});
}