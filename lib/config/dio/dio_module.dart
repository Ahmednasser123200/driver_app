import 'package:dio/dio.dart';
import 'package:driver_app/config/dio/auth_interceptor.dart';
import 'package:driver_app/core/constants/api_strings/api_strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio dio(AuthInterceptors authInterceptor) {
    // The order service fans out to the address service per store, which can
    // take 10+ seconds per page, so the receive window is deliberately larger
    // than the connect window. It stays env-tunable for slower setups.
    final receiveTimeoutSeconds =
        int.tryParse(dotenv.env['API_RECEIVE_TIMEOUT_SECONDS'] ?? '') ?? 45;

    final dio = Dio(
      BaseOptions(
        baseUrl: ApiStrings.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: Duration(seconds: receiveTimeoutSeconds),
      ),
    );
    dio.interceptors.add(authInterceptor);
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          error: true,
        ),
      );
    }
    return dio;
  }
}
