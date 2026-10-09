import 'package:dio/dio.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/dio/dio_failure_mapper.dart';
import 'package:driver_app/config/errors/app_failure.dart';

Future<BaseResponse<T>> executeApi<T>(Future<T> Function() call) async {
  try {
    return Success<T>(await call());
  } on DioException catch (e) {
    return Error<T>(mapDioExceptionToAppFailure(e));
  } catch (_) {
    return Error<T>(const UnknownFailure());
  }
}
