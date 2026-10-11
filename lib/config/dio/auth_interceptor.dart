import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/services/token_storage_service.dart';

@lazySingleton
class AuthInterceptors extends Interceptor {
  final TokenStorageService _tokenStorage;

  AuthInterceptors(this._tokenStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
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
      await _tokenStorage.clear();
    }

    handler.next(err);
  }

  Future<void> setToken(String token, {bool persist = true}) async {
    await _tokenStorage.saveAccessToken(token, persist: persist);
  }

  Future<void> clearToken() async {
    await _tokenStorage.clear();
  }

  Future<bool> get hasToken async {
    final token = await _tokenStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
