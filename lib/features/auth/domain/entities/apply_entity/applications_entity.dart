import 'package:equatable/equatable.dart';

class ApplicationEntity extends Equatable {
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
  final String gender;
  final String vehicleLicencePath;
  final String idImagePath;

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
    required this.vehicleLicencePath,
    required this.idImagePath,
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
    vehicleLicencePath,
    idImagePath,
  ];
}
