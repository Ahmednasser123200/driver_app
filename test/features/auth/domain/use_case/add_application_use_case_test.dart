import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/applications_entity.dart';
import 'package:driver_app/features/auth/domain/repo/auth_repo.dart';
import 'package:driver_app/features/auth/domain/use_case/add_application_use_case.dart';

class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late MockAuthRepo mockAuthRepo;
  late AddApplicationUseCase useCase;

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    useCase = AddApplicationUseCase(mockAuthRepo);
  });

  group('AddApplicationUseCase', () {
    test('calls repository.addApplication with correct entity and returns Success', () async {
      final applicationEntity = ApplicationEntity(
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
        vehicleLicenceFile: File('license.jpg'),
        idImage: File('id.jpg'),
      );

      when(() => mockAuthRepo.addApplication(applicationEntity))
          .thenAnswer((_) async => const Success(null));

      final result = await useCase.execute(applicationEntity);

      expect(result, isA<Success<void>>());
      verify(() => mockAuthRepo.addApplication(applicationEntity)).called(1);
    });

    test('calls repository.addApplication and returns Error when repository fails', () async {
      final applicationEntity = ApplicationEntity(
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
        vehicleLicenceFile: File('license.jpg'),
        idImage: File('id.jpg'),
      );

      when(() => mockAuthRepo.addApplication(applicationEntity))
          .thenAnswer((_) async => const Error(ServerFailure()));

      final result = await useCase.execute(applicationEntity);

      expect(result, isA<Error<void>>());
      verify(() => mockAuthRepo.addApplication(applicationEntity)).called(1);
    });
  });
}
