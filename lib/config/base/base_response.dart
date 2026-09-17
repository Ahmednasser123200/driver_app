import 'package:driver_app/config/errors/handle_error_exception.dart';

sealed class BaseResponse<T> {
}

class Success<T> extends BaseResponse<T> {
  final T data;

  Success(this.data);
}

class Error<T> extends BaseResponse<T> {
  final String message;
  final Exception exception;
  Error(this.exception) : message = HandelErrorException().handelErrorexception(exception);
}