import 'package:injectable/injectable.dart';

import '../../../../../config/base/base_cubit.dart';
import '../../../../../config/base/base_response.dart';
import '../../../../../config/base/base_state.dart';
import '../../../../../core/services/media_service.dart';
import '../../../domain/entities/apply_entity/applications_entity.dart';
import '../../../domain/entities/apply_entity/country_entity.dart';
import '../../../domain/entities/apply_entity/vehicle_type_entity.dart';
import '../../../domain/use_case/add_application_use_case.dart';
import '../../../domain/use_case/get_countries_use_case.dart';
import '../../../domain/use_case/get_vehicle_types_use_case.dart';
import 'apply_intent.dart';
import 'apply_state.dart';
import 'apply_ui_event.dart'; // الملف الجديد

@injectable
class ApplyCubit extends BaseCubit<ApplyState, ApplyUiEvent> { // استخدام ApplyUiEvent بدلاً من BaseUiEvent
  ApplyCubit(
      this._addApplicationUseCase,
      this._getCountriesUseCase,
      this._getVehicleTypesUseCase,
      this._mediaService,
      ) : super(const ApplyState()) {
    processIntent(const LoadInitialDataIntent());
  }

  final AddApplicationUseCase _addApplicationUseCase;
  final GetCountriesUseCase _getCountriesUseCase;
  final GetVehicleTypesUseCase _getVehicleTypesUseCase;
  final MediaService _mediaService;

  void processIntent(ApplyIntent intent) {
    switch (intent) {
      case LoadInitialDataIntent():
        _loadInitialData();
      case ChangeFirstNameIntent(:final value):
        emit(state.copyWith(firstName: value));
      case ChangeSecondNameIntent(:final value):
        emit(state.copyWith(secondName: value));
      case ChangeVehicleNumberIntent(:final value):
        emit(state.copyWith(vehicleNumber: value));
      case ChangeEmailIntent(:final value):
        emit(state.copyWith(email: value));
      case ChangePhoneIntent(:final value):
        emit(state.copyWith(phoneNumber: value));
      case ChangeNationalIdIntent(:final value):
        emit(state.copyWith(nationalId: value));
      case ChangePasswordIntent(:final value):
        emit(state.copyWith(password: value));
      case ChangeConfirmPasswordIntent(:final value):
        emit(state.copyWith(confirmPassword: value));
      case ChangeGenderIntent(:final value):
        emit(state.copyWith(gender: value));
      case SelectCountryIntent(:final country):
        emit(
          state.copyWith(
            selectedCountry: country,
            countryCode: '+${country.phoneCode}',
          ),
        );
      case SelectVehicleTypeIntent(:final vehicleType):
        emit(
          state.copyWith(
            selectedVehicleType: vehicleType,
            vehicleType: vehicleType.id,
          ),
        );
      case PickLicenseImageIntent():
        _pickLicenseImage();
      case PickIdImageIntent():
        _pickIdImage();
      case SubmitApplicationIntent():
        _submit();
    }
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadCountries(),
      _loadVehicleTypes(),
    ]);
  }

  Future<void> _loadCountries() async {
    emit(state.copyWith(countriesStatus: const BaseState(isLoading: true)));
    final response = await _getCountriesUseCase.execute();

    switch (response) {
      case Success<List<CountryEntity>>(:final data):
        final firstCountry = data.isNotEmpty ? data.first : null;
        emit(
          state.copyWith(
            countriesStatus: BaseState(isLoading: false, data: data),
            selectedCountry: firstCountry,
            countryCode: firstCountry != null ? '+${firstCountry.phoneCode}' : state.countryCode,
          ),
        );
      case Error<List<CountryEntity>>(:final failure):
        emit(
          state.copyWith(
            countriesStatus: BaseState(
              isLoading: false,
              errorMessage: failure.toString(),
            ),
          ),
        );
    }
  }

  Future<void> _loadVehicleTypes() async {
    emit(state.copyWith(vehicleTypesStatus: const BaseState(isLoading: true)));
    final response = await _getVehicleTypesUseCase.execute();

    switch (response) {
      case Success<List<VehicleTypeEntity>>(:final data):
        final firstVehicle = data.isNotEmpty ? data.first : null;
        emit(
          state.copyWith(
            vehicleTypesStatus: BaseState(isLoading: false, data: data),
            selectedVehicleType: firstVehicle,
            vehicleType: firstVehicle != null ? firstVehicle.id : state.vehicleType,
          ),
        );
      case Error<List<VehicleTypeEntity>>(:final failure):
        emit(
          state.copyWith(
            vehicleTypesStatus: BaseState(
              isLoading: false,
              errorMessage: failure.toString(),
            ),
          ),
        );
    }
  }

  Future<void> _pickLicenseImage() async {
    final path = await _mediaService.pickImageFromGallery();
    if (path != null) {
      emit(state.copyWith(vehicleLicencePath: path));
    }
  }

  Future<void> _pickIdImage() async {
    final path = await _mediaService.pickImageFromGallery();
    if (path != null) {
      emit(state.copyWith(idImagePath: path));
    }
  }

  Future<void> _submit() async {
    if (state.selectedCountry == null) {
      emitEvent(const ApplyCountryMissingEvent());
      return;
    }
    if (state.selectedVehicleType == null) {
      emitEvent(const ApplyVehicleTypeMissingEvent());
      return;
    }
    if (state.gender == null) {
      emitEvent(const ApplyGenderMissingEvent());
      return;
    }
    if (state.vehicleLicencePath == null || state.vehicleLicencePath!.isEmpty) {
      emitEvent(const ApplyLicenseMissingEvent());
      return;
    }
    if (state.idImagePath == null || state.idImagePath!.isEmpty) {
      emitEvent(const ApplyIdImageMissingEvent());
      return;
    }

    emit(state.copyWith(applyStatus: const BaseState(isLoading: true)));

    final response = await _addApplicationUseCase.execute(
      ApplicationEntity(
        countryCode: state.countryCode,
        firstName: state.firstName,
        secondName: state.secondName,
        vehicleType: state.vehicleType,
        vehicleNumber: state.vehicleNumber,
        email: state.email,
        phoneNumber: state.phoneNumber,
        nationalId: state.nationalId,
        password: state.password,
        confirmPassword: state.confirmPassword,
        gender: state.gender!,
        vehicleLicencePath: state.vehicleLicencePath!,
        idImagePath: state.idImagePath!,
      ),
    );

    switch (response) {
      case Success<void>():
        emit(state.copyWith(applyStatus: const BaseState(isLoading: false)));
        emitEvent(const ApplySuccessEvent());
      case Error<void>(:final failure):
        emit(
          state.copyWith(
            applyStatus: BaseState(
              isLoading: false,
              errorMessage: failure.toString(),
            ),
          ),
        );
        emitEvent(ApplyFailureEvent(failure));
    }
  }
}