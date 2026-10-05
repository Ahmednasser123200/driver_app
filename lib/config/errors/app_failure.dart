import 'package:driver_app/config/utils/auth_validators.dart';

sealed class AppFailure {
  const AppFailure();
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(this.validationError);

  final ValidationError validationError;
}

class InternetConnectionFailure extends AppFailure {
  const InternetConnectionFailure();
}

class TimeoutFailure extends AppFailure {
  const TimeoutFailure();
}

class CancelFailure extends AppFailure {
  const CancelFailure();
}

class BadCertificateFailure extends AppFailure {
  const BadCertificateFailure();
}

class BadRequestFailure extends AppFailure {
  final String? serverMessage;

  const BadRequestFailure({this.serverMessage});
}

class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure({this.serverMessage});

  final String? serverMessage;
}

class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure();
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure();
}

class MethodNotAllowedFailure extends AppFailure {
  const MethodNotAllowedFailure();
}

class ConflictFailure extends AppFailure {
  const ConflictFailure({this.serverMessage});

  final String? serverMessage;
}

class UnprocessableEntityFailure extends AppFailure {
  const UnprocessableEntityFailure({this.serverMessage});

  final String? serverMessage;
}

class TooManyRequestsFailure extends AppFailure {
  const TooManyRequestsFailure();
}

class ServerFailure extends AppFailure {
  const ServerFailure({this.statusCode, this.serverMessage});

  final int? statusCode;
  final String? serverMessage;
}

class NotDriverAccountFailure extends AppFailure {
  // final String? serverMessage;
  //
  //
  // const NotDriverAccountFailure({this.serverMessage});
}

class UnknownFailure extends AppFailure {
  const UnknownFailure();
}
class BadResponse extends AppFailure{
  const BadResponse();
}
