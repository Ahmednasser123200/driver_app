sealed class OrderDetailsEvent {
  const OrderDetailsEvent();
}

class GetDriverOrderDetailsEvent extends OrderDetailsEvent {
  final String orderId;

  const GetDriverOrderDetailsEvent({required this.orderId});
}

class UpdateOrderStatusEvent extends OrderDetailsEvent {
  final String orderId;
  final String newStatus;

  const UpdateOrderStatusEvent({
    required this.orderId,
    required this.newStatus,
  });
}

class StartLocationReportingEvent extends OrderDetailsEvent {
  const StartLocationReportingEvent();
}

class StopLocationReportingEvent extends OrderDetailsEvent {
  const StopLocationReportingEvent();
}
