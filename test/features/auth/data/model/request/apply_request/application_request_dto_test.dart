import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/auth/data/model/request/apply_request/application_request_dto.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/applications_entity.dart';

void main() {
  group('ApplicationRequestDto', () {
    test('fromEntity maps ApplicationEntity to ApplicationRequestDto correctly', () {
      final licenseFile = File('test_license.jpg');
      final idImage = File('test_id.jpg');

      final entity = ApplicationEntity(
        countryCode: '+20',
        firstName: 'John',
        secondName: 'Doe',
        vehicleType: VehicleType.car,
        vehicleNumber: 'ABC 123',
        email: 'john@example.com',
        phoneNumber: '01234567890',
        nationalId: '12345678901234',
        password: 'password123',
        confirmPassword: 'password123',
        gender: 'Male',
        vehicleLicenceFile: licenseFile,
        idImage: idImage,
      );

      final dto = ApplicationRequestDto.fromEntity(entity);

      expect(dto.countryCode, '+20');
      expect(dto.firstName, 'John');
      expect(dto.secondName, 'Doe');
      expect(dto.vehicleType, 'Car');
      expect(dto.vehicleNumber, 'ABC 123');
      expect(dto.email, 'john@example.com');
      expect(dto.phoneNumber, '1234567890'); // Trunk zero stripped
      expect(dto.nationalId, '12345678901234');
      expect(dto.password, 'password123');
      expect(dto.confirmPassword, 'password123');
      expect(dto.gender, 'Male');
      expect(dto.vehicleLicenceFile, licenseFile);
      expect(dto.idImage, idImage);
    });
  });
}
