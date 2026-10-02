import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/auth/data/model/data_dto.dart';
import 'package:driver_app/features/auth/data/model/request/login_request/login_request.dart';
import 'package:driver_app/features/auth/data/model/response/login_response/login_response.dart';
import 'package:driver_app/features/auth/data/model/user_dto.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_credentials.dart';

void main() {
  group('LoginCredentials', () {
    test('creates LoginCredentials instance correctly with given properties', () {
      const credentials = LoginCredentials(
        email: 'test@driver.com',
        password: 'password123',
      );

      expect(credentials.email, equals('test@driver.com'));
      expect(credentials.password, equals('password123'));
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

      expect(request.email, equals('driver@test.com'));
      expect(request.password, equals('password123'));
      expect(request.deviceId, equals('device_123'));
      expect(request.fcmToken, equals('fcm_token_123'));

      final serialized = request.toJson();
      expect(serialized['email'], equals('driver@test.com'));
      expect(serialized['password'], equals('password123'));
      expect(serialized['deviceId'], equals('device_123'));
      expect(serialized['fcmToken'], equals('fcm_token_123'));
    });

    test('loginRequestFromJson and loginRequestToJson helper functions work correctly', () {
      final jsonString = json.encode({
        'email': 'test@test.com',
        'password': 'pass',
        'deviceId': 'd1',
        'fcmToken': 'f1',
      });

      final request = loginRequestFromJson(jsonString);
      expect(request.email, equals('test@test.com'));

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
      expect(dto1.id, equals('123'));
      expect(dto1.fullName, equals('John Driver'));

      final jsonMap2 = {'id': 456};
      final dto2 = UserDto.fromJson(jsonMap2);
      expect(dto2.id, equals('456'));
    });

    test('toJson serializes UserDto correctly', () {
      final dto = UserDto(
        id: 'usr_100',
        fullName: 'Test Driver',
        email: 'test@driver.com',
        phoneNumber: '0123456789',
        gender: 'Male',
        role: 'Driver',
        photoUrl: 'http://example.com/photo.jpg',
        status: 'Active',
        isActive: true,
      );

      final jsonMap = dto.toJson();
      expect(jsonMap['id'], equals('usr_100'));
      expect(jsonMap['fullName'], equals('Test Driver'));
      expect(jsonMap['email'], equals('test@driver.com'));
      expect(jsonMap['phoneNumber'], equals('0123456789'));
      expect(jsonMap['gender'], equals('Male'));
      expect(jsonMap['role'], equals('Driver'));
      expect(jsonMap['photoUrl'], equals('http://example.com/photo.jpg'));
      expect(jsonMap['status'], equals('Active'));
      expect(jsonMap['isActive'], isTrue);
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
      expect(entity.id, equals('usr_1'));
      expect(entity.fullName, equals('Jane Driver'));
      expect(entity.email, equals('jane@driver.com'));
      expect(entity.phoneNumber, equals('0987654321'));
      expect(entity.gender, equals('Female'));
      expect(entity.role, equals('Driver'));
      expect(entity.status, equals('Active'));
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
      expect(entity.status, equals('Active'));
    });

    test('toUserEntity handles status fallback to Inactive when status is null and isActive is false', () {
      final dto = UserDto(
        id: 'usr_3',
        fullName: 'Driver Three',
        status: null,
        isActive: false,
      );

      final entity = dto.toUserEntity();
      expect(entity.status, equals('Inactive'));
    });
  });

  group('LoginDataDto', () {
    test('fromJson, toJson and toLoginEntity work as expected', () {
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
      expect(dataDto.accessToken, equals('access_123'));
      expect(dataDto.refreshToken, equals('refresh_123'));
      expect(dataDto.expiresIn, equals(3600));
      expect(dataDto.driverStatus, equals('Approved'));
      expect(dataDto.user?.fullName, equals('Driver One'));

      final jsonOutput = dataDto.toJson();
      expect(jsonOutput['accessToken'], equals('access_123'));

      final loginEntity = dataDto.toLoginEntity();
      expect(loginEntity.accessToken, equals('access_123'));
      expect(loginEntity.refreshToken, equals('refresh_123'));
      expect(loginEntity.expiresIn, equals(3600));
      expect(loginEntity.driverStatus, equals('Approved'));
      expect(loginEntity.user?.fullName, equals('Driver One'));
    });

    test('toLoginEntity handles null fields gracefully with default values', () {
      final dataDto = LoginDataDto();
      final entity = dataDto.toLoginEntity();

      expect(entity.accessToken, isEmpty);
      expect(entity.refreshToken, isEmpty);
      expect(entity.expiresIn, equals(0));
      expect(entity.driverStatus, isEmpty);
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
      expect(response.errorCode, equals(200));
      expect(response.message, equals('Success'));
      expect(response.data?.accessToken, equals('token_abc'));
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
      expect(response.errorCode, equals(200));
      expect(response.message, equals('Login successful.'));
      expect(response.data?.accessToken, equals('direct_access_token'));
      expect(response.data?.driverStatus, equals('Approved'));
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
      expect(jsonMap['errorCode'], equals(200));
      expect(jsonMap['message'], equals('OK'));
      expect(jsonMap['data'], isNotNull);
    });
  });
}
