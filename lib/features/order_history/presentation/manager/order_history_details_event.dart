sealed class OrderHistoryDetailsEvent {}

class GetOrderHistoryDetailsEvent extends OrderHistoryDetailsEvent {
  final String orderId;
  GetOrderHistoryDetailsEvent({required this.orderId});
}