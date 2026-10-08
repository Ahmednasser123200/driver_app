import '../../../../../config/base/base_ui_event.dart';
import '../../../../../config/errors/app_failure.dart';
import '../../../domain/entities/apply_entity/country_entity.dart';
import '../../../domain/entities/apply_entity/vehicle_type_entity.dart';

sealed class ApplyIntent {
  const ApplyIntent();
}

class LoadInitialDataIntent extends ApplyIntent {
  const LoadInitialDataIntent();
}

class ChangeFirstNameIntent extends ApplyIntent {
  final String value;
  const ChangeFirstNameIntent(this.value);
}

class ChangeSecondNameIntent extends ApplyIntent {
  final String value;
  const ChangeSecondNameIntent(this.value);
}

class ChangeVehicleNumberIntent extends ApplyIntent {
  final String value;
  const ChangeVehicleNumberIntent(this.value);
}

class ChangeEmailIntent extends ApplyIntent {
  final String value;
  const ChangeEmailIntent(this.value);
}

class ChangePhoneIntent extends ApplyIntent {
  final String value;
  const ChangePhoneIntent(this.value);
}

class ChangeNationalIdIntent extends ApplyIntent {
  final String value;
  const ChangeNationalIdIntent(this.value);
}

class ChangePasswordIntent extends ApplyIntent {
  final String value;
  const ChangePasswordIntent(this.value);
}

class ChangeConfirmPasswordIntent extends ApplyIntent {
  final String value;
  const ChangeConfirmPasswordIntent(this.value);
}

class ChangeGenderIntent extends ApplyIntent {
  final String value;
  const ChangeGenderIntent(this.value);
}

class SelectCountryIntent extends ApplyIntent {
  final CountryEntity country;
  const SelectCountryIntent(this.country);
}

class SelectVehicleTypeIntent extends ApplyIntent {
  final VehicleTypeEntity vehicleType;
  const SelectVehicleTypeIntent(this.vehicleType);
}

class PickLicenseImageIntent extends ApplyIntent {
  const PickLicenseImageIntent();
}

class PickIdImageIntent extends ApplyIntent {
  const PickIdImageIntent();
}

class SubmitApplicationIntent extends ApplyIntent {
  const SubmitApplicationIntent();
}

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

class ApplyGenderMissingEvent extends ApplyUiEvent {
  const ApplyGenderMissingEvent();
}

class ApplyLicenseMissingEvent extends ApplyUiEvent {
  const ApplyLicenseMissingEvent();
}

class ApplyIdImageMissingEvent extends ApplyUiEvent {
  const ApplyIdImageMissingEvent();
}
