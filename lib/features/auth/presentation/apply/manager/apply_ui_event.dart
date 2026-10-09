import '../../../../../config/base/base_ui_event.dart';
import '../../../../../config/errors/app_failure.dart';

sealed class ApplyUiEvent extends BaseUiEvent {
  const ApplyUiEvent();
}

class ApplySuccessEvent extends ApplyUiEvent {
  const ApplySuccessEvent();
}

class ApplyFailureEvent extends ApplyUiEvent {
  final AppFailure failure;
  const ApplyFailureEvent(this.failure);
}

class ApplyCountryMissingEvent extends ApplyUiEvent {
  const ApplyCountryMissingEvent();
}

class ApplyVehicleTypeMissingEvent extends ApplyUiEvent {
  const ApplyVehicleTypeMissingEvent();
}

class ApplyGenderMissingEvent extends ApplyUiEvent {
  const ApplyGenderMissingEvent();
}

class ApplyLicenseMissingEvent extends ApplyUiEvent {
  const ApplyLicenseMissingEvent();
}

class ApplyIdImageMissingEvent extends ApplyUiEvent {
  const ApplyIdImageMissingEvent();
}