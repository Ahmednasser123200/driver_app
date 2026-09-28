import 'package:dio/dio.dart';

import '../errors/app_failure.dart';

AppFailure mapDioExceptionToAppFailure(DioException error) {
  switch (error.type) {
    case DioExceptionType.badCertificate:
      return const BadCertificateFailure();
    case DioExceptionType.badResponse:
      return _mapServerFailure(error);
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const TimeoutFailure();
    case DioExceptionType.cancel:
      return const CancelFailure();
    case DioExceptionType.connectionError:
      return const InternetConnectionFailure();
    case DioExceptionType.unknown:
      return const UnknownFailure();
  }
}

AppFailure _mapServerFailure(DioException error) {
  final statusCode = error.response?.statusCode;
  final serverMessage = _extractServerMessage(error.response?.data);

  switch (statusCode) {
    case 400:
      return BadRequestFailure(serverMessage: serverMessage);
    case 401:
      return const UnauthorizedFailure();
    case 403:
      return const ForbiddenFailure();
    case 404:
      return const NotFoundFailure();
    case 405:
      return const MethodNotAllowedFailure();
    case 409:
      return ConflictFailure(serverMessage: serverMessage);
    case 422:
      return UnprocessableEntityFailure(serverMessage: serverMessage);
    case 429:
      return const TooManyRequestsFailure();
    default:
      return ServerFailure(statusCode: statusCode);
  }
}

String? _extractServerMessage(dynamic data) {
  if (data is Map) {
    final message = data['message'] ?? data['error'] ?? data['detail'];
    if (message is String && message.isNotEmpty) return message;
  }
  return null;
}
