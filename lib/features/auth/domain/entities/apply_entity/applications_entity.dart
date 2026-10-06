import 'dart:io';

import 'package:equatable/equatable.dart';

enum VehicleType {
  car,
  motorcycle;

  String get apiValue {
    switch (this) {
      case VehicleType.car:
        return '1';
      case VehicleType.motorcycle:
        return '2';
    }
  }

  String get displayName {
    switch (this) {
      case VehicleType.car:
        return 'Car';
      case VehicleType.motorcycle:
        return 'Motorcycle';
    }
  }
}

class ApplicationEntity extends Equatable {
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
  final String gender;
  final File vehicleLicenceFile;
  final File idImage;

  const ApplicationEntity({
    required this.countryCode,
    required this.firstName,
    required this.secondName,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.email,
    required this.phoneNumber,
    required this.nationalId,
    required this.password,
    required this.confirmPassword,
    required this.gender,
    required this.vehicleLicenceFile,
    required this.idImage,
  });

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