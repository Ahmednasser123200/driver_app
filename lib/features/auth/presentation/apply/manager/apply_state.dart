import 'package:equatable/equatable.dart';
import '../../../../../config/base/base_state.dart';

import '../../../domain/entities/apply_entity/country_entity.dart';
import '../../../domain/entities/apply_entity/vehicle_type_entity.dart';

class ApplyState extends Equatable {
  final String countryCode;
  final String firstName;
  final String secondName;
  final String vehicleType;
  final String vehicleNumber;
  final String email;
  final String phoneNumber;
  final String nationalId;
  final String password;
  final String confirmPassword;
  final String? gender;
  final String? vehicleLicencePath;
  final String? idImagePath;
  final CountryEntity? selectedCountry;
  final VehicleTypeEntity? selectedVehicleType;
  final BaseState<void> applyStatus;
  final BaseState<List<CountryEntity>> countriesStatus;
  final BaseState<List<VehicleTypeEntity>> vehicleTypesStatus;

  const ApplyState({
    this.countryCode = '+20',
    this.firstName = '',
    this.secondName = '',
    this.vehicleType = '',
    this.vehicleNumber = '',
    this.email = '',
    this.phoneNumber = '',
    this.nationalId = '',
    this.password = '',
    this.confirmPassword = '',
    this.gender,
    this.vehicleLicencePath,
    this.idImagePath,
    this.selectedCountry,
    this.selectedVehicleType,
    this.applyStatus = const BaseState(),
    this.countriesStatus = const BaseState(),
    this.vehicleTypesStatus = const BaseState(),
  });

  ApplyState copyWith({
    String? countryCode,
    String? firstName,
    String? secondName,
    String? vehicleType,
    String? vehicleNumber,
    String? email,
    String? phoneNumber,
    String? nationalId,
    String? password,
    String? confirmPassword,
    String? gender,
    String? vehicleLicencePath,
    String? idImagePath,
    CountryEntity? selectedCountry,
    VehicleTypeEntity? selectedVehicleType,
    BaseState<void>? applyStatus,
    BaseState<List<CountryEntity>>? countriesStatus,
    BaseState<List<VehicleTypeEntity>>? vehicleTypesStatus,
  }) {
    return ApplyState(
      countryCode: countryCode ?? this.countryCode,
      firstName: firstName ?? this.firstName,
      secondName: secondName ?? this.secondName,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nationalId: nationalId ?? this.nationalId,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      gender: gender ?? this.gender,
      vehicleLicencePath: vehicleLicencePath ?? this.vehicleLicencePath,
      idImagePath: idImagePath ?? this.idImagePath,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedVehicleType: selectedVehicleType ?? this.selectedVehicleType,
      applyStatus: applyStatus ?? this.applyStatus,
      countriesStatus: countriesStatus ?? this.countriesStatus,
      vehicleTypesStatus: vehicleTypesStatus ?? this.vehicleTypesStatus,
    );
  }

  @override
  List<Object?> get props => [
    countryCode,
    firstName,
    secondName,
    vehicleType,
    vehicleNumber,
    email,
    phoneNumber,
    nationalId,
    password,
    confirmPassword,
    gender,
    vehicleLicencePath,
    idImagePath,
    selectedCountry,
    selectedVehicleType,
    applyStatus,
    countriesStatus,
    vehicleTypesStatus,
  ];
}
