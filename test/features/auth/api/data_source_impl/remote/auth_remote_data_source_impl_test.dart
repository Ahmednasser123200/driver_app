import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:driver_app/features/auth/api/client/auth_api_client.dart';
import 'package:driver_app/features/auth/api/data_source_impl/remote/auth_remote_data_source_impl.dart';
import 'package:driver_app/features/auth/data/model/request/login_request/login_request.dart';
import 'package:driver_app/features/auth/data/model/response/login_response/login_response.dart';
import 'package:driver_app/features/auth/data/model/data_dto.dart';

class MockAuthApiClient extends Mock implements AuthApiClient {}

void main() {
  late MockAuthApiClient mockAuthApiClient;
  late RemoteDataSourceImpl remoteDataSource;

  setUpAll(() {
    registerFallbackValue(LoginRequest());
  });

  setUp(() {
    mockAuthApiClient = MockAuthApiClient();
    remoteDataSource = RemoteDataSourceImpl(mockAuthApiClient);
  });

  group('RemoteDataSourceImpl - login', () {
    test('calls AuthApiClient.login with correct request and returns LoginResponse', () async {
      final loginRequest = LoginRequest(
        email: 'driver@example.com',
        password: 'password123',
        deviceId: 'device_id',
        fcmToken: 'fcm_token',
      );

      final expectedResponse = LoginResponse(
        isSuccess: true,
        errorCode: 200,
        message: 'Login successful.',
        data: LoginDataDto(
          accessToken: 'test_access_token',
          refreshToken: 'test_refresh_token',
          expiresIn: 3600,
          driverStatus: 'Approved',
        ),
      );

      when(() => mockAuthApiClient.login(any())).thenAnswer((_) async => expectedResponse);

      final result = await remoteDataSource.login(loginRequest);

      expect(result, equals(expectedResponse));
      verify(() => mockAuthApiClient.login(loginRequest)).called(1);
    });

    test('rethrows exception when AuthApiClient.login fails', () async {
      final loginRequest = LoginRequest(
        email: 'driver@example.com',
        password: 'wrong_password',
      );

      final exception = Exception('Network error');

      when(() => mockAuthApiClient.login(any())).thenThrow(exception);

      expect(() => remoteDataSource.login(loginRequest), throwsA(equals(exception)));
      verify(() => mockAuthApiClient.login(loginRequest)).called(1);
    });
  });
}
