import 'package:driver_app/config/utils/auth_validators.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';

String? mapValidationErrorToMessage(
  ValidationError? error,
  AppLocalizations l10n,
) {
  if (error == null) return null;

  return switch (error) {
    ValidationError.emailRequired => l10n.emailRequired,
    ValidationError.emailInvalid => l10n.emailInvalid,
    ValidationError.passwordRequired => l10n.passwordRequired,
    ValidationError.passwordMinLength => l10n.passwordMinLength,
    ValidationError.passwordStrongRules => l10n.passwordStrongRules,
    ValidationError.confirmPasswordRequired => l10n.confirmPasswordRequired,
    ValidationError.confirmPasswordMismatch => l10n.confirmPasswordMismatch,
    ValidationError.usernameRequired => l10n.usernameRequired,
    ValidationError.usernameMinLength => l10n.usernameMinLength,
    ValidationError.firstNameRequired => l10n.firstNameRequired,
    ValidationError.firstNameOnlyLetters => l10n.firstNameOnlyLetters,
    ValidationError.lastNameRequired => l10n.lastNameRequired,
    ValidationError.lastNameOnlyLetters => l10n.lastNameOnlyLetters,
    ValidationError.phoneRequired => l10n.phoneRequired,
    ValidationError.phoneInvalid => l10n.phoneInvalid,
    ValidationError.fieldRequired => l10n.fieldRequired,
    ValidationError.fieldMinLength => l10n.fieldMinLength,
  };
}