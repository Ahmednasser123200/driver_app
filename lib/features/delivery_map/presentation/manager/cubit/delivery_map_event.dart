import 'package:driver_app/features/delivery_map/domain/models/address_model.dart';
import 'package:driver_app/features/delivery_map/domain/models/delivery_map_target.dart';
import 'package:geolocator/geolocator.dart';

sealed class DeliveryMapEvent {
  const DeliveryMapEvent();
}

class InitDeliveryMapEvent extends DeliveryMapEvent {
  final AddressModel? pickupAddress;
  final AddressModel? userAddress;
  final DeliveryMapTarget? initialTarget;

  const InitDeliveryMapEvent({
    this.pickupAddress,
    this.userAddress,
    this.initialTarget,
  });
}

class SwitchTargetEvent extends DeliveryMapEvent {
  final DeliveryMapTarget target;

  const SwitchTargetEvent(this.target);
}

class StartDriverLocationTrackingEvent extends DeliveryMapEvent {
  const StartDriverLocationTrackingEvent();
}

class StopDriverLocationTrackingEvent extends DeliveryMapEvent {
  const StopDriverLocationTrackingEvent();
}

class DriverPositionUpdatedEvent extends DeliveryMapEvent {
  final Position position;

  const DriverPositionUpdatedEvent(this.position);
}

class CallPhoneEvent extends DeliveryMapEvent {
  final String? phoneNumber;

  const CallPhoneEvent(this.phoneNumber);
}

class OpenWhatsAppEvent extends DeliveryMapEvent {
  final String? phoneNumber;

  const OpenWhatsAppEvent(this.phoneNumber);
}
