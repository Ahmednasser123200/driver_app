import 'package:dio/dio.dart';
import 'package:driver_app/core/constants/storage_keys.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthInterceptors extends Interceptor {
  AuthInterceptors(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: StorageKeys.kUserToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _handleUnauthorized();
    }

    handler.next(err);
  }

  Future<void> _handleUnauthorized() async {
    await _storage.delete(key: StorageKeys.kUserToken);
  }

  Future<void> setToken(String token) async {
    await _storage.write(key: StorageKeys.kUserToken, value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: StorageKeys.kUserToken);
  }

  Future<bool> get hasToken async {
    final token = await _storage.read(key: StorageKeys.kUserToken);
    return token != null && token.isNotEmpty;
  }
}