import 'dart:async';
import 'dart:io';

import 'package:driver_app/config/base/base_cubit.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/applications_entity.dart';
import 'package:driver_app/features/auth/presentation/apply/manager/apply_state.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/use_case/add_application_use_case.dart';
import 'apply_event.dart';

@injectable
class ApplyCubit extends BaseCubit<BaseState<ApplyState>, BaseUiEvent> {
  ApplyCubit(this._addApplicationUseCase)
      : super(const BaseState(data: ApplyState()));

  final AddApplicationUseCase _addApplicationUseCase;

  final StreamController<ApplyEvent> _applyEventController =
  StreamController<ApplyEvent>.broadcast();

  Stream<ApplyEvent> get applyEventStream => _applyEventController.stream;

  void _emitApplyEvent(ApplyEvent event) {
    if (_applyEventController.isClosed) return;
    _applyEventController.add(event);
  }

  ApplyState get _data => state.data!;

  void _update(ApplyState data) => emit(state.copyWith(data: data));

  void onCountryChanged(String value) =>
      _update(_data.copyWith(countryCode: value));
  void onFirstNameChanged(String value) =>
      _update(_data.copyWith(firstName: value));
  void onSecondNameChanged(String value) =>
      _update(_data.copyWith(secondName: value));
  void onVehicleTypeChanged(VehicleType value) =>
      _update(_data.copyWith(vehicleType: value));
  void onVehicleNumberChanged(String value) =>
      _update(_data.copyWith(vehicleNumber: value));
  void onEmailChanged(String value) => _update(_data.copyWith(email: value));
  void onPhoneChanged(String value) =>
      _update(_data.copyWith(phoneNumber: value));
  void onNationalIdChanged(String value) =>
      _update(_data.copyWith(nationalId: value));
  void onPasswordChanged(String value) =>
      _update(_data.copyWith(password: value));
  void onConfirmPasswordChanged(String value) =>
      _update(_data.copyWith(confirmPassword: value));
  void onGenderChanged(String value) => _update(_data.copyWith(gender: value));
  void onLicenseFilePicked(File file) =>
      _update(_data.copyWith(vehicleLicenceFile: file));
  void onIdImagePicked(File file) => _update(_data.copyWith(idImage: file));

  Future<void> submit() async {
    final data = _data;

    if (data.gender == null) {
      _emitApplyEvent(const ApplyGenderMissingEvent());
      return;
    }
    if (data.vehicleLicenceFile == null) {
      _emitApplyEvent(const ApplyLicenseMissingEvent());
      return;
    }
    if (data.idImage == null) {
      _emitApplyEvent(const ApplyIdImageMissingEvent());
      return;
    }

    emit(state.copyWith(isLoading: true));

    final response = await _addApplicationUseCase.execute(
      ApplicationEntity(
        countryCode: data.countryCode,
        firstName: data.firstName,
        secondName: data.secondName,
        vehicleType: data.vehicleType,
        vehicleNumber: data.vehicleNumber,
        email: data.email,
        phoneNumber: data.phoneNumber,
        nationalId: data.nationalId,
        password: data.password,
        confirmPassword: data.confirmPassword,
        gender: data.gender!,
        vehicleLicenceFile: data.vehicleLicenceFile!,
        idImage: data.idImage!,
      ),
    );

    emit(state.copyWith(isLoading: false));

    switch (response) {
      case Success<void>():
        _emitApplyEvent(const ApplySuccessEvent());
      case Error<void>(:final failure):
        _emitApplyEvent(ApplyFailureEvent(failure));
    }
  }

  @override
  Future<void> close() async {
    await _applyEventController.close();
    return super.close();
  }
}