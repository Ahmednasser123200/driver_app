import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/applications_entity.dart';

void main() {
  group('VehicleType', () {
    test('apiValue returns correct string representation', () {
      expect(VehicleType.car.apiValue, '1');
      expect(VehicleType.motorcycle.apiValue, '2');
    });

    test('displayName returns user-facing string', () {
      expect(VehicleType.car.displayName, 'Car');
      expect(VehicleType.motorcycle.displayName, 'Motorcycle');
    });
  });

  group('ApplicationEntity', () {
    test('supports value equality', () {
      final file1 = File('file1.jpg');
      final file2 = File('file2.jpg');

      final entity1 = ApplicationEntity(
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
        vehicleLicenceFile: file1,
        idImage: file2,
      );

      final entity2 = ApplicationEntity(
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
        vehicleLicenceFile: file1,
        idImage: file2,
      );

      expect(entity1, equals(entity2));
    });
  });
}
