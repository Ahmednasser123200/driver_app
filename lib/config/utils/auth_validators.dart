enum ValidationError {
  emailRequired,
  emailInvalid,
  passwordRequired,
  passwordMinLength,
  passwordStrongRules,
  confirmPasswordRequired,
  confirmPasswordMismatch,
  usernameRequired,
  usernameMinLength,
  firstNameRequired,
  firstNameOnlyLetters,
  lastNameRequired,
  lastNameOnlyLetters,
  phoneRequired,
  phoneInvalid,
  fieldRequired,
  fieldMinLength,
}

class AuthValidators {
  AuthValidators._(); // prevent instantiation

  static ValidationError? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationError.emailRequired;
    }
    final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return ValidationError.emailInvalid;
    }
    return null;
  }

  static ValidationError? password(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationError.passwordRequired;
    }
    if (value.length < 8) {
      return ValidationError.passwordMinLength;
    }
    return null;
  }

  /// Stricter policy for creating a new password (registration / reset),
  /// as opposed to [password] which only checks an existing password is present.
  static ValidationError? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationError.passwordRequired;
    }
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',
    );
    if (!passwordRegex.hasMatch(value)) {
      return ValidationError.passwordStrongRules;
    }
    return null;
  }

  static ValidationError? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return ValidationError.confirmPasswordRequired;
    }
    if (value != original) {
      return ValidationError.confirmPasswordMismatch;
    }
    return null;
  }

  static ValidationError? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationError.usernameRequired;
    }
    if (value.trim().length < 3) {
      return ValidationError.usernameMinLength;
    }
    return null;
  }

  static ValidationError? addressFields(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationError.fieldRequired;
    }
    if (value.trim().length < 3) {
      return ValidationError.fieldMinLength;
    }
    return null;
  }

  static ValidationError? firstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationError.firstNameRequired;
    }
    if (!RegExp(r'^[a-zA-Z]{2,30}$').hasMatch(value)) {
      return ValidationError.firstNameOnlyLetters;
    }
    return null;
  }

  static ValidationError? lastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationError.lastNameRequired;
    }
    if (!RegExp(r'^[a-zA-Z]{2,30}$').hasMatch(value)) {
      return ValidationError.lastNameOnlyLetters;
    }
    return null;
  }

  static ValidationError? phone(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationError.phoneRequired;
    }
    if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(value)) {
      return ValidationError.phoneInvalid;
    }
    return null;
  }
}
