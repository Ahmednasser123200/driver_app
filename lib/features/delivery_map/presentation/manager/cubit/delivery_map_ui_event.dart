part of '../../../../../../config/base/base_ui_event.dart';

sealed class DeliveryMapUiEvent extends BaseUiEvent {
  const DeliveryMapUiEvent();
}

class DeliveryMapLocationPermissionDenied extends DeliveryMapUiEvent {
  const DeliveryMapLocationPermissionDenied();
}

class DeliveryMapLocationServiceDisabled extends DeliveryMapUiEvent {
  const DeliveryMapLocationServiceDisabled();
}

class DeliveryMapLaunchUrlFailed extends DeliveryMapUiEvent {
  final String url;

  const DeliveryMapLaunchUrlFailed(this.url);
}
