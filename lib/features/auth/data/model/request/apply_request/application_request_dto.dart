import 'dart:io';

import '../../../../../../config/utils/phone_number_formatter.dart';
import '../../../../domain/entities/apply_entity/applications_entity.dart';

class ApplicationRequestDto {
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
  final File? vehicleLicenceFile;
  final File? idImage;

  const ApplicationRequestDto({
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
    this.vehicleLicenceFile,
    this.idImage,
  });

  factory ApplicationRequestDto.fromEntity(ApplicationEntity entity) {
    return ApplicationRequestDto(
      countryCode: entity.countryCode,
      firstName: entity.firstName,
      secondName: entity.secondName,
      vehicleType: entity.vehicleType.apiValue,
      vehicleNumber: entity.vehicleNumber,
      email: entity.email,
      phoneNumber: PhoneNumberFormatter.stripLeadingTrunkZero(entity.phoneNumber),
      nationalId: entity.nationalId,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
      gender: entity.gender,
      vehicleLicenceFile: entity.vehicleLicenceFile,
      idImage: entity.idImage,
    );
  }
}