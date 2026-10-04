import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/api/service/secure_storage.dart';

@lazySingleton
class AuthInterceptors extends Interceptor {
  AuthInterceptors(this._storageService);

  final SecureStorageService _storageService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storageService.getAccessToken();
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
      await _storageService.clear();
    }

    handler.next(err);
  }

  Future<void> setToken(String token, {bool rememberMe = true}) async {
    await _storageService.saveAccessToken(token, rememberMe: rememberMe);
  }

  Future<void> clearToken() async {
    await _storageService.clear();
  }

  Future<bool> get hasToken async {
    final token = await _storageService.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
