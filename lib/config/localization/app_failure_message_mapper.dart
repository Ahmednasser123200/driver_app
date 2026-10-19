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
    MethodNotAllowedFailure() => l10n.failureMethodNotAllowed,
    ConflictFailure(:final serverMessage) =>
      serverMessage?.isNotEmpty == true ? serverMessage! : l10n.failureConflict,
    AlreadyActiveOrderFailure() => l10n.failureAlreadyActiveOrder,
    UnprocessableEntityFailure(:final serverMessage) =>
      serverMessage?.isNotEmpty == true
          ? serverMessage!
          : l10n.failureUnprocessableEntity,
    TooManyRequestsFailure() => l10n.failureTooManyRequests,
    ServerFailure() => l10n.failureServerError,
    UnknownFailure() => l10n.failureUnknown,
    InvalidPhoneFailure() => l10n.failureInvalidPhone,
    ContactLaunchFailure() => l10n.failureContactLaunch,
    WhatsAppUnavailableFailure() => l10n.failureWhatsAppUnavailable,
  };
}
