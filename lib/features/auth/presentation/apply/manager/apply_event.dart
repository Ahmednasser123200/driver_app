import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';

sealed class ApplyEvent extends BaseUiEvent {
  const ApplyEvent();
}

class ApplySuccessEvent extends ApplyEvent {
  const ApplySuccessEvent();
}

class ApplyFailureEvent extends ApplyEvent {
  final AppFailure failure;

  const ApplyFailureEvent(this.failure);
}

class ApplyGenderMissingEvent extends ApplyEvent {
  const ApplyGenderMissingEvent();
}

class ApplyLicenseMissingEvent extends ApplyEvent {
  const ApplyLicenseMissingEvent();
}

class ApplyIdImageMissingEvent extends ApplyEvent {
  const ApplyIdImageMissingEvent();
}