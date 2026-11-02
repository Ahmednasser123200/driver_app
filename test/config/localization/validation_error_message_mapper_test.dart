import 'package:driver_app/config/localization/validation_error_message_mapper.dart';
import 'package:driver_app/config/utils/auth_validators.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  test('returns null when the error is null', () {
    expect(mapValidationErrorToMessage(null, l10n), isNull);
  });

  group('mapValidationErrorToMessage maps every ValidationError', () {
    final expectations = <ValidationError, String Function(AppLocalizations)>{
      ValidationError.emailRequired: (l) => l.emailRequired,
      ValidationError.emailInvalid: (l) => l.emailInvalid,
      ValidationError.passwordRequired: (l) => l.passwordRequired,
      ValidationError.passwordMinLength: (l) => l.passwordMinLength,
      ValidationError.passwordStrongRules: (l) => l.passwordStrongRules,
      ValidationError.confirmPasswordRequired: (l) => l.confirmPasswordRequired,
      ValidationError.confirmPasswordMismatch: (l) => l.confirmPasswordMismatch,
      ValidationError.usernameRequired: (l) => l.usernameRequired,
      ValidationError.usernameMinLength: (l) => l.usernameMinLength,
      ValidationError.firstNameRequired: (l) => l.firstNameRequired,
      ValidationError.firstNameOnlyLetters: (l) => l.firstNameOnlyLetters,
      ValidationError.lastNameRequired: (l) => l.lastNameRequired,
      ValidationError.lastNameOnlyLetters: (l) => l.lastNameOnlyLetters,
      ValidationError.phoneRequired: (l) => l.phoneRequired,
      ValidationError.phoneInvalid: (l) => l.phoneInvalid,
      ValidationError.fieldRequired: (l) => l.fieldRequired,
      ValidationError.fieldMinLength: (l) => l.fieldMinLength,
    };

    test('every enum value has an expectation', () {
      expect(expectations.length, ValidationError.values.length);
    });

    expectations.forEach((error, pick) {
      test('maps $error', () {
        expect(mapValidationErrorToMessage(error, l10n), pick(l10n));
      });
    });
  });

  test('each ValidationError maps to a non-empty message', () {
    for (final error in ValidationError.values) {
      expect(
        mapValidationErrorToMessage(error, l10n),
        isNotEmpty,
        reason: '$error produced an empty message',
      );
    }
  });
}