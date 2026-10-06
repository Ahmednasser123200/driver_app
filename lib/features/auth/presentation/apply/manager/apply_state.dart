import 'dart:io';

import 'package:equatable/equatable.dart';

import 'package:driver_app/features/auth/domain/entities/apply_entity/applications_entity.dart';

class ApplyState extends Equatable {
  final String countryCode;
  final String firstName;
  final String secondName;
  final VehicleType vehicleType;
  final String vehicleNumber;
  final String email;
  final String phoneNumber;
  final String nationalId;
  final String password;
  final String confirmPassword;
  final String? gender;
  final File? vehicleLicenceFile;
  final File? idImage;

  const ApplyState({
    this.countryCode = '+20',
    this.firstName = '',
    this.secondName = '',
    this.vehicleType = VehicleType.car,
    this.vehicleNumber = '',
    this.email = '',
    this.phoneNumber = '',
    this.nationalId = '',
    this.password = '',
    this.confirmPassword = '',
    this.gender,
    this.vehicleLicenceFile,
    this.idImage,
  });

  ApplyState copyWith({
    String? countryCode,
    String? firstName,
    String? secondName,
    VehicleType? vehicleType,
    String? vehicleNumber,
    String? email,
    String? phoneNumber,
    String? nationalId,
    String? password,
    String? confirmPassword,
    String? gender,
    File? vehicleLicenceFile,
    File? idImage,
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
      vehicleLicenceFile: vehicleLicenceFile ?? this.vehicleLicenceFile,
      idImage: idImage ?? this.idImage,
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
        vehicleLicenceFile,
        idImage,
      ];
}