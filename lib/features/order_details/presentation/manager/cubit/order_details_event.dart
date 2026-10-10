
sealed class OrderDetailsEvent {}

class GetDriverOrderDetailsEvent extends OrderDetailsEvent {
  final String orderId;

  GetDriverOrderDetailsEvent({required this.orderId});
}

class ReportDriverLocationEvent extends OrderDetailsEvent {
final double lat;
  final double lng;
  final String recordedAt;

  ReportDriverLocationEvent({required this.lat, required this.lng, required this.recordedAt});
}

class UpdateOrderStatusEvent extends OrderDetailsEvent {
  final String orderId;
final String newStatus;
  UpdateOrderStatusEvent({required this.orderId, required this.newStatus});
}
