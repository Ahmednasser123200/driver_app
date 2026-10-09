import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/auth/api/client/auth_client.dart';
import 'package:driver_app/features/auth/api/data_source_impl/remote/auth_remote_data_source_impl.dart';
import 'package:driver_app/features/auth/data/model/request/apply_request/application_request_dto.dart';
import 'package:driver_app/features/auth/data/model/response/apply_response/application_dto.dart';
import 'package:driver_app/features/auth/data/model/response/apply_response/application_response_dto.dart';

import 'package:driver_app/features/auth/data/model/response/apply_response/country_dto.dart';
import 'package:driver_app/features/auth/data/model/response/apply_response/vehicle_type_dto.dart';
import 'package:driver_app/features/auth/data/model/response/apply_response/vehicle_types_response_dto.dart';

class MockAuthClient extends Mock implements AuthClient {}

void main() {
  late MockAuthClient mockAuthClient;
  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    mockAuthClient = MockAuthClient();
    dataSource = AuthRemoteDataSourceImpl(mockAuthClient);
  });

  group('AuthRemoteDataSourceImpl - addApplication', () {
    final requestDto = ApplicationRequestDto(
      countryCode: '+20',
      firstName: 'John',
      secondName: 'Doe',
      vehicleType: 'Car',
      vehicleNumber: 'ABC 123',
      email: 'john@example.com',
      phoneNumber: '1234567890',
      nationalId: '12345678901234',
      password: 'password123',
      confirmPassword: 'password123',
      gender: 'Male',
      vehicleLicenceFile: File('license.jpg'),
      idImage: File('id.jpg'),
    );

    test('returns Success when API call succeeds', () async {
      final responseDto = ApplicationResponseDto(
        success: true,
        message: 'Success',
        data: ApplicationDto(applicationId: '1', status: 'pending'),
      );

      when(
        () => mockAuthClient.addApplication(any(), any(), any()),
      ).thenAnswer((_) async => responseDto);

      final result = await dataSource.addApplication(requestDto);

      expect(result, isA<Success<ApplicationResponseDto>>());
      expect((result as Success<ApplicationResponseDto>).data, responseDto);
      verify(
        () => mockAuthClient.addApplication(
          requestDto.toFieldMap(),
          requestDto.vehicleLicenceFile,
          requestDto.idImage,
        ),
      ).called(1);
    });

    test('returns Error when API call fails with DioException', () async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/drivers/applications'),
        error: 'Server Error',
        type: DioExceptionType.connectionTimeout,
      );

      when(
        () => mockAuthClient.addApplication(any(), any(), any()),
      ).thenThrow(dioException);

      final result = await dataSource.addApplication(requestDto);

      expect(result, isA<Error<ApplicationResponseDto>>());
    });
  });

  group('AuthRemoteDataSourceImpl - getVehicleTypes', () {
    test(
      'returns Success with unwrapped vehicle types when API succeeds',
      () async {
        const vehicleList = [
          VehicleTypeDto(id: 1, name: 'Car'),
          VehicleTypeDto(id: 2, name: 'Motorcycle'),
        ];
        const responseDto = VehicleTypesResponseDto(
          success: true,
          message: 'Request completed successfully',
          data: vehicleList,
        );

        when(
          () => mockAuthClient.getVehicleTypes(),
        ).thenAnswer((_) async => responseDto);

        final result = await dataSource.getVehicleTypes();

        expect(result, isA<Success<List<VehicleTypeDto>>>());
        expect((result as Success<List<VehicleTypeDto>>).data, vehicleList);
        verify(() => mockAuthClient.getVehicleTypes()).called(1);
      },
    );

    test('returns Success with empty list when data is null', () async {
      const responseDto = VehicleTypesResponseDto(
        success: true,
        message: 'Empty',
        data: null,
      );

      when(
        () => mockAuthClient.getVehicleTypes(),
      ).thenAnswer((_) async => responseDto);

      final result = await dataSource.getVehicleTypes();

      expect(result, isA<Success<List<VehicleTypeDto>>>());
      expect((result as Success<List<VehicleTypeDto>>).data, isEmpty);
    });

    test(
      'returns Error when getVehicleTypes fails with DioException',
      () async {
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/v1/vehicle-types'),
          error: 'Not Found',
          type: DioExceptionType.badResponse,
        );

        when(() => mockAuthClient.getVehicleTypes()).thenThrow(dioException);

        final result = await dataSource.getVehicleTypes();

        expect(result, isA<Error<List<VehicleTypeDto>>>());
      },
    );
  });

  group('AuthRemoteDataSourceImpl - getCountries', () {
    test('returns Success with country list when API succeeds', () async {
      const countryList = [
        CountryDto(isoCode: 'EG', name: 'Egypt', phoneCode: '20', flag: '🇪🇬'),
      ];

      when(
        () => mockAuthClient.getCountries(),
      ).thenAnswer((_) async => countryList);

      final result = await dataSource.getCountries();

      expect(result, isA<Success<List<CountryDto>>>());
      expect((result as Success<List<CountryDto>>).data, countryList);
      verify(() => mockAuthClient.getCountries()).called(1);
    });
  });
}
