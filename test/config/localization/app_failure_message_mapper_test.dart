import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/config/localization/app_failure_message_mapper.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('mapAppFailureToMessage - server-message-free failures', () {
    final expectations = <AppFailure, String>{
      const InternetConnectionFailure(): '',
      const TimeoutFailure(): '',
      const CancelFailure(): '',
      const BadCertificateFailure(): '',
      const UnauthorizedFailure(): '',
      const ForbiddenFailure(): '',
      const NotFoundFailure(): '',
      const MethodNotAllowedFailure(): '',
      const TooManyRequestsFailure(): '',
      const ServerFailure(): '',
      const UnknownFailure(): '',
    };

    expectations.forEach((failure, key) {
      test('maps ${failure.runtimeType}', () {
        final message = mapAppFailureToMessage(failure, l10n);
        expect(message, isNotEmpty, reason: 'expected a non-empty message');
        if (key.isNotEmpty) {
          expect(message, key);
        }
      });
    });

    test('each failure maps to a distinct message', () {
      final messages = <String>{
        mapAppFailureToMessage(const InternetConnectionFailure(), l10n),
        mapAppFailureToMessage(const TimeoutFailure(), l10n),
        mapAppFailureToMessage(const CancelFailure(), l10n),
        mapAppFailureToMessage(const BadCertificateFailure(), l10n),
        mapAppFailureToMessage(const UnauthorizedFailure(), l10n),
        mapAppFailureToMessage(const ForbiddenFailure(), l10n),
        mapAppFailureToMessage(const NotFoundFailure(), l10n),
        mapAppFailureToMessage(const MethodNotAllowedFailure(), l10n),
        mapAppFailureToMessage(const TooManyRequestsFailure(), l10n),
        mapAppFailureToMessage(const ServerFailure(), l10n),
        mapAppFailureToMessage(const UnknownFailure(), l10n),
      };

      expect(messages.length, 11);
    });
  });

  group('mapAppFailureToMessage - failures carrying a serverMessage', () {
    test('BadRequestFailure prefers a non-empty serverMessage', () {
      expect(
        mapAppFailureToMessage(
          const BadRequestFailure(serverMessage: 'Invalid payload'),
          l10n,
        ),
        'Invalid payload',
      );
    });

    test('ConflictFailure prefers a non-empty serverMessage', () {
      expect(
        mapAppFailureToMessage(
          const ConflictFailure(
            serverMessage: 'You already have an active delivery in progress.',
          ),
          l10n,
        ),
        'You already have an active delivery in progress.',
      );
    });

    test('UnprocessableEntityFailure prefers a non-empty serverMessage', () {
      expect(
        mapAppFailureToMessage(
          const UnprocessableEntityFailure(serverMessage: 'Invalid status'),
          l10n,
        ),
        'Invalid status',
      );
    });

    test('falls back to the localized message when serverMessage is null', () {
      expect(
        mapAppFailureToMessage(const BadRequestFailure(), l10n),
        l10n.failureBadRequest,
      );
      expect(
        mapAppFailureToMessage(const ConflictFailure(), l10n),
        l10n.failureConflict,
      );
      expect(
        mapAppFailureToMessage(const UnprocessableEntityFailure(), l10n),
        l10n.failureUnprocessableEntity,
      );
    });

    test('falls back to the localized message when serverMessage is empty', () {
      expect(
        mapAppFailureToMessage(
          const BadRequestFailure(serverMessage: ''),
          l10n,
        ),
        l10n.failureBadRequest,
      );
      expect(
        mapAppFailureToMessage(const ConflictFailure(serverMessage: ''), l10n),
        l10n.failureConflict,
      );
      expect(
        mapAppFailureToMessage(
          const UnprocessableEntityFailure(serverMessage: ''),
          l10n,
        ),
        l10n.failureUnprocessableEntity,
      );
    });

    test('ServerFailure ignores statusCode and returns the generic message', () {
      expect(
        mapAppFailureToMessage(const ServerFailure(statusCode: 503), l10n),
        l10n.failureServerError,
      );
    });
  });
}