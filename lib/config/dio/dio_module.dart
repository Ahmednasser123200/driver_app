import 'package:dio/dio.dart';
import 'package:driver_app/config/dio/auth_interceptor.dart';
import 'package:driver_app/core/constants/api_strings/api_strings.dart';
import 'package:injectable/injectable.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio dio(AuthInterceptors authInterceptor) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiStrings.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    dio.interceptors.add(authInterceptor);
    return dio;
  }
}
