import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';

String mapAppFailureToMessage(AppFailure failure, AppLocalizations l10n) {
  return switch (failure) {
    InternetConnectionFailure() => l10n.failureInternetConnection,
    TimeoutFailure() => l10n.failureTimeout,
    CancelFailure() => l10n.failureCancel,
    BadCertificateFailure() => l10n.failureBadCertificate,
    BadRequestFailure(:final serverMessage) =>
      serverMessage?.isNotEmpty == true
          ? serverMessage!
          : l10n.failureBadRequest,
    UnauthorizedFailure() => l10n.failureUnauthorized,
    ForbiddenFailure() => l10n.failureForbidden,
    NotFoundFailure() => l10n.failureNotFound,
    TooManyRequestsFailure() => l10n.failureTooManyRequests,
    ServerFailure(:final serverMessage) =>
      serverMessage?.isNotEmpty == true
          ? serverMessage!
          : l10n.failureServerError,
    UnknownFailure() => l10n.failureUnknown,
  };
}
