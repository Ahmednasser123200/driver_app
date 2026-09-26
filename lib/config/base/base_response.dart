import 'package:driver_app/config/errors/app_failure.dart';

sealed class BaseResponse<T> {
  const BaseResponse();
}

class Success<T> extends BaseResponse<T> {
  final T data;

  const Success(this.data);
}

class Error<T> extends BaseResponse<T> {
  final AppFailure failure;

  const Error(this.failure);
}
