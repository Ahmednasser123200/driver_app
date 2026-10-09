import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/auth/data/model/request/apply_request/application_request_dto.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/applications_entity.dart';

void main() {
  group('ApplicationRequestDto', () {
    test(
      'fromEntity maps ApplicationEntity to ApplicationRequestDto correctly',
      () {
        const licensePath = 'test_license.jpg';
        const idImagePath = 'test_id.jpg';

        const entity = ApplicationEntity(
          countryCode: '+20',
          firstName: 'John',
          secondName: 'Doe',
          vehicleType: '1',
          vehicleNumber: 'ABC 123',
          email: 'john@example.com',
          phoneNumber: '01234567890',
          nationalId: '12345678901234',
          password: 'password123',
          confirmPassword: 'password123',
          gender: 'Male',
          vehicleLicencePath: licensePath,
          idImagePath: idImagePath,
        );

        final dto = ApplicationRequestDto.fromEntity(entity);

        expect(dto.countryCode, '+20');
        expect(dto.firstName, 'John');
        expect(dto.secondName, 'Doe');
        expect(dto.vehicleType, '1');
        expect(dto.vehicleNumber, 'ABC 123');
        expect(dto.email, 'john@example.com');
        expect(dto.phoneNumber, '1234567890'); // Trunk zero stripped
        expect(dto.nationalId, '12345678901234');
        expect(dto.password, 'password123');
        expect(dto.confirmPassword, 'password123');
        expect(dto.gender, 'Male');
        expect(dto.vehicleLicenceFile.path, licensePath);
        expect(dto.idImage.path, idImagePath);
      },
    );

    test(
      'toFieldMap returns correct PascalCase field map matching API contract',
      () {
        final licenseFile = File('test_license.jpg');
        final idImage = File('test_id.jpg');

        final dto = ApplicationRequestDto(
          countryCode: '+20',
          firstName: 'John',
          secondName: 'Doe',
          vehicleType: '1',
          vehicleNumber: 'ABC 123',
          email: 'john@example.com',
          phoneNumber: '1234567890',
          nationalId: '12345678901234',
          password: 'password123',
          confirmPassword: 'password123',
          gender: 'Male',
          vehicleLicenceFile: licenseFile,
          idImage: idImage,
        );

        final map = dto.toFieldMap();

        expect(map, {
          'CountryCode': '+20',
          'FirstName': 'John',
          'SecondName': 'Doe',
          'VehicleType': '1',
          'VehicleNumber': 'ABC 123',
          'Email': 'john@example.com',
          'PhoneNumber': '1234567890',
          'NationalId': '12345678901234',
          'Password': 'password123',
          'ConfirmPassword': 'password123',
          'Gender': 'Male',
        });
      },
    );
  });
}
