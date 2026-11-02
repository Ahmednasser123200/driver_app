import 'package:dio/dio.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/dio/dio_failure_mapper.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:flutter/foundation.dart';

Future<BaseResponse<T>> excecuteApiCall<T>(Future<T> Function() request) async {
  try {
    return Success<T>(await request());
  } on DioException catch (e) {
    return Error<T>(mapDioExceptionToAppFailure(e));
  } catch (e, st) {
    debugPrint('REAL ERROR => $e\n$st');
    return Error<T>(const UnknownFailure());
  }
}
