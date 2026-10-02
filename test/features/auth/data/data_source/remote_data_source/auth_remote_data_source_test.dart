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
        () => mockAuthClient.addApplication(
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => responseDto);

      final result = await dataSource.addApplication(requestDto);

      expect(result, isA<Success<ApplicationResponseDto>>());
      expect((result as Success<ApplicationResponseDto>).data, responseDto);
      verify(
        () => mockAuthClient.addApplication(
          requestDto.countryCode,
          requestDto.firstName,
          requestDto.secondName,
          requestDto.vehicleType,
          requestDto.vehicleNumber,
          requestDto.email,
          requestDto.phoneNumber,
          requestDto.nationalId,
          requestDto.password,
          requestDto.confirmPassword,
          requestDto.gender,
          requestDto.vehicleLicenceFile,
          requestDto.idImage,
        ),
      ).called(1);
    });

    test('returns Error when API call fails with DioException', () async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/v1/drivers/applications'),
        error: 'Server Error',
        type: DioExceptionType.connectionTimeout,
      );

      when(
        () => mockAuthClient.addApplication(
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenThrow(dioException);

      final result = await dataSource.addApplication(requestDto);

      expect(result, isA<Error<ApplicationResponseDto>>());
    });
  });
}
