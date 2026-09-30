import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart';
import 'package:driver_app/features/auth/data/model/request/apply_request/application_request_dto.dart';
import 'package:driver_app/features/auth/data/model/response/apply_response/application_response_dto.dart';
import 'package:driver_app/features/auth/data/repo_impl/auth_repo_impl.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/applications_entity.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class FakeApplicationRequestDto extends Fake implements ApplicationRequestDto {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeApplicationRequestDto());
  });

  late MockAuthRemoteDataSource mockRemoteDataSource;
  late AuthRepoImpl repoImpl;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    repoImpl = AuthRepoImpl(mockRemoteDataSource);
  });

  group('AuthRepoImpl - addApplication', () {
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

    test('returns Success<void> when remote data source returns Success', () async {
      final responseDto = ApplicationResponseDto(
        success: true,
        message: 'Success',
      );

      when(() => mockRemoteDataSource.addApplication(any()))
          .thenAnswer((_) async => Success(responseDto));

      final result = await repoImpl.addApplication(applicationEntity);

      expect(result, isA<Success<void>>());
      verify(() => mockRemoteDataSource.addApplication(any())).called(1);
    });

    test('returns Error when remote data source returns Error', () async {
      const failure = ServerFailure();

      when(() => mockRemoteDataSource.addApplication(any()))
          .thenAnswer((_) async => Error(failure));

      final result = await repoImpl.addApplication(applicationEntity);

      expect(result, isA<Error<void>>());
      expect((result as Error<void>).failure, failure);
      verify(() => mockRemoteDataSource.addApplication(any())).called(1);
    });
  });
}
