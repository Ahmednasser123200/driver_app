import 'package:driver_app/features/order_details/domain/entities/driver_status_update.dart';

sealed class OrderDetailsEvent {
  const OrderDetailsEvent();
}

class GetDriverOrderDetailsEvent extends OrderDetailsEvent {
  final String orderId;

  GetDriverOrderDetailsEvent({required this.orderId});
}

class UpdateOrderStatusEvent extends OrderDetailsEvent {
  final String orderId;
  final DriverStatusUpdate newStatus;

  UpdateOrderStatusEvent({required this.orderId, required this.newStatus});
}

class CallRecipientEvent extends OrderDetailsEvent {
  const CallRecipientEvent();
}

class WhatsAppRecipientEvent extends OrderDetailsEvent {
  const WhatsAppRecipientEvent();
}

class CallStoreEvent extends OrderDetailsEvent {
  const CallStoreEvent();
}

class WhatsAppStoreEvent extends OrderDetailsEvent {
  const WhatsAppStoreEvent();
}
