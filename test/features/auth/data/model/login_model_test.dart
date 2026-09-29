import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/auth/data/model/request/login_request/login_request.dart';
import 'package:driver_app/features/auth/data/model/response/login_response/login_response.dart';
import 'package:driver_app/features/auth/data/model/data_dto.dart';
import 'package:driver_app/features/auth/data/model/user_dto.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_credentials.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_entity.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/user_entity.dart';

void main() {
  group('LoginCredentials', () {
    test('creates LoginCredentials instance correctly', () {
      const credentials = LoginCredentials(
        email: 'test@driver.com',
        password: 'password123',
      );

      expect(credentials.email, 'test@driver.com');
      expect(credentials.password, 'password123');
    });
  });

  group('LoginRequest', () {
    test('fromJson and toJson work correctly', () {
      final jsonMap = {
        'email': 'driver@test.com',
        'password': 'password123',
        'deviceId': 'device_123',
        'fcmToken': 'fcm_token_123',
      };

      final request = LoginRequest.fromJson(jsonMap);

      expect(request.email, 'driver@test.com');
      expect(request.password, 'password123');
      expect(request.deviceId, 'device_123');
      expect(request.fcmToken, 'fcm_token_123');

      final serialized = request.toJson();
      expect(serialized['email'], 'driver@test.com');
      expect(serialized['password'], 'password123');
      expect(serialized['deviceId'], 'device_123');
      expect(serialized['fcmToken'], 'fcm_token_123');
    });

    test('loginRequestFromJson and loginRequestToJson helper functions work correctly', () {
      final jsonString = json.encode({
        'email': 'test@test.com',
        'password': 'pass',
        'deviceId': 'd1',
        'fcmToken': 'f1',
      });

      final request = loginRequestFromJson(jsonString);
      expect(request.email, 'test@test.com');

      final stringOutput = loginRequestToJson(request);
      expect(stringOutput, contains('test@test.com'));
    });
  });

  group('UserDto', () {
    test('fromJson parses String and num id correctly', () {
      final jsonMap1 = {
        'id': '123',
        'fullName': 'John Driver',
        'email': 'john@driver.com',
        'phoneNumber': '1234567890',
        'gender': 'Male',
        'role': 'Driver',
        'photoUrl': 'http://photo.url',
        'status': 'Active',
        'isActive': true,
      };

      final dto1 = UserDto.fromJson(jsonMap1);
      expect(dto1.id, '123');
      expect(dto1.fullName, 'John Driver');

      final jsonMap2 = {'id': 456};
      final dto2 = UserDto.fromJson(jsonMap2);
      expect(dto2.id, '456');
    });

    test('toUserEntity converts UserDto to UserEntity accurately', () {
      final dto = UserDto(
        id: 'usr_1',
        fullName: 'Jane Driver',
        email: 'jane@driver.com',
        phoneNumber: '0987654321',
        gender: 'Female',
        role: 'Driver',
        photoUrl: 'http://img.com/1.png',
        status: 'Active',
        isActive: true,
      );

      final entity = dto.toUserEntity();
      expect(entity.id, 'usr_1');
      expect(entity.fullName, 'Jane Driver');
      expect(entity.email, 'jane@driver.com');
      expect(entity.phoneNumber, '0987654321');
      expect(entity.gender, 'Female');
      expect(entity.role, 'Driver');
      expect(entity.status, 'Active');
    });

    test('toUserEntity handles status fallback to isActive when status is null', () {
      final dto = UserDto(
        id: 'usr_2',
        fullName: 'Driver Two',
        email: 'two@driver.com',
        phoneNumber: '111',
        gender: 'Male',
        role: 'Driver',
        status: null,
        isActive: true,
      );

      final entity = dto.toUserEntity();
      expect(entity.status, 'Active');
    });
  });

  group('LoginDataDto', () {
    test('fromJson and toLoginEntity work as expected', () {
      final jsonMap = {
        'accessToken': 'access_123',
        'refreshToken': 'refresh_123',
        'expiresIn': 3600,
        'driverStatus': 'Approved',
        'user': {
          'id': 'u1',
          'fullName': 'Driver One',
          'email': 'one@driver.com',
          'phoneNumber': '123',
          'gender': 'Male',
          'role': 'Driver',
          'status': 'Active',
        },
      };

      final dataDto = LoginDataDto.fromJson(jsonMap);
      expect(dataDto.accessToken, 'access_123');
      expect(dataDto.refreshToken, 'refresh_123');
      expect(dataDto.expiresIn, 3600);
      expect(dataDto.driverStatus, 'Approved');
      expect(dataDto.user?.fullName, 'Driver One');

      final loginEntity = dataDto.toLoginEntity();
      expect(loginEntity.accessToken, 'access_123');
      expect(loginEntity.refreshToken, 'refresh_123');
      expect(loginEntity.expiresIn, 3600);
      expect(loginEntity.driverStatus, 'Approved');
      expect(loginEntity.user?.fullName, 'Driver One');
    });

    test('toLoginEntity handles null fields gracefully', () {
      final dataDto = LoginDataDto();
      final entity = dataDto.toLoginEntity();

      expect(entity.accessToken, '');
      expect(entity.refreshToken, '');
      expect(entity.expiresIn, 0);
      expect(entity.driverStatus, '');
      expect(entity.user, isNull);
    });
  });

  group('LoginResponse', () {
    test('fromJson handles standard response json with data key', () {
      final jsonMap = {
        'isSuccess': true,
        'errorCode': 200,
        'message': 'Success',
        'data': {
          'accessToken': 'token_abc',
          'refreshToken': 'ref_abc',
          'expiresIn': 1800,
          'driverStatus': 'Pending',
        },
      };

      final response = LoginResponse.fromJson(jsonMap);
      expect(response.isSuccess, isTrue);
      expect(response.errorCode, 200);
      expect(response.message, 'Success');
      expect(response.data?.accessToken, 'token_abc');
    });

    test('fromJson handles direct accessToken root response json', () {
      final jsonMap = {
        'accessToken': 'direct_access_token',
        'refreshToken': 'direct_refresh_token',
        'expiresIn': 3600,
        'driverStatus': 'Approved',
      };

      final response = LoginResponse.fromJson(jsonMap);
      expect(response.isSuccess, isTrue);
      expect(response.errorCode, 200);
      expect(response.message, 'Login successful.');
      expect(response.data?.accessToken, 'direct_access_token');
      expect(response.data?.driverStatus, 'Approved');
    });

    test('toJson serializes correctly', () {
      final response = LoginResponse(
        isSuccess: true,
        errorCode: 200,
        message: 'OK',
        data: LoginDataDto(accessToken: 'token'),
      );

      final jsonMap = response.toJson();
      expect(jsonMap['isSuccess'], isTrue);
      expect(jsonMap['errorCode'], 200);
      expect(jsonMap['message'], 'OK');
      expect(jsonMap['data'], isNotNull);
    });
  });
}
