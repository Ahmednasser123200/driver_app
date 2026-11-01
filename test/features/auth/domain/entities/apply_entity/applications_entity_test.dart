import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/applications_entity.dart';

void main() {
  group('ApplicationEntity', () {
    test('supports value equality', () {
      const entity1 = ApplicationEntity(
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
        vehicleLicencePath: 'file1.jpg',
        idImagePath: 'file2.jpg',
      );

      const entity2 = ApplicationEntity(
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
        vehicleLicencePath: 'file1.jpg',
        idImagePath: 'file2.jpg',
      );

      expect(entity1, equals(entity2));
    });
  });
}
