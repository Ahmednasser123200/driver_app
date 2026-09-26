import 'package:dio/dio.dart';
import 'package:driver_app/config/dio/auth_interceptor.dart';
import 'package:driver_app/core/constants/storage_keys.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late MockSecureStorage storage;
  late AuthInterceptors interceptor;

  setUp(() {
    storage = MockSecureStorage();
    interceptor = AuthInterceptors(storage);
  });

  group('onRequest', () {
    test('adds Bearer token from storage to request headers', () async {
      when(
        () => storage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => 'test-token');

      final options = RequestOptions(path: '/orders');
      await interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers['Authorization'], 'Bearer test-token');
      verify(() => storage.read(key: StorageKeys.kUserToken)).called(1);
    });

    test('does not add Authorization header when no token is stored', () async {
      when(
        () => storage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);

      final options = RequestOptions(path: '/orders');
      await interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('onError', () {
    test('deletes token on 401 response', () async {
      when(
        () => storage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});

      final error = DioException(
        requestOptions: RequestOptions(path: '/orders'),
        response: Response(
          requestOptions: RequestOptions(path: '/orders'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      await interceptor.onError(error, MockErrorInterceptorHandler());

      verify(() => storage.delete(key: StorageKeys.kUserToken)).called(1);
    });

    test('does not delete token on non-401 response', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/orders'),
        response: Response(
          requestOptions: RequestOptions(path: '/orders'),
          statusCode: 500,
        ),
        type: DioExceptionType.badResponse,
      );

      await interceptor.onError(error, MockErrorInterceptorHandler());

      verifyNever(() => storage.delete(key: any(named: 'key')));
    });
  });

  group('token helpers', () {
    test('setToken writes token to storage', () async {
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      await interceptor.setToken('abc');

      verify(
        () => storage.write(key: StorageKeys.kUserToken, value: 'abc'),
      ).called(1);
    });

    test('clearToken deletes token from storage', () async {
      when(
        () => storage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});

      await interceptor.clearToken();

      verify(() => storage.delete(key: StorageKeys.kUserToken)).called(1);
    });

    test('hasToken is true when token exists', () async {
      when(
        () => storage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => 'token');

      expect(await interceptor.hasToken, isTrue);
    });

    test('hasToken is false when no token exists', () async {
      when(
        () => storage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);

      expect(await interceptor.hasToken, isFalse);
    });
  });
}
