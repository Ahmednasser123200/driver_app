sealed class AppFailure {
  const AppFailure();
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
  const BadRequestFailure({this.serverMessage});

  final String? serverMessage;
}

class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure();
}

class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure();
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure();
}

class TooManyRequestsFailure extends AppFailure {
  const TooManyRequestsFailure();
}

class ServerFailure extends AppFailure {
  const ServerFailure({this.statusCode, this.serverMessage});

  final int? statusCode;
  final String? serverMessage;
}

class UnknownFailure extends AppFailure {
  const UnknownFailure();
}