import 'package:driver_app/config/utils/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthValidators.email', () {
    test('returns emailRequired when value is null', () {
      expect(AuthValidators.email(null), ValidationError.emailRequired);
    });

    test('returns emailRequired when value is empty or whitespace', () {
      expect(AuthValidators.email(''), ValidationError.emailRequired);
      expect(AuthValidators.email('   '), ValidationError.emailRequired);
    });

    test('returns emailInvalid for malformed addresses', () {
      expect(AuthValidators.email('not-an-email'), ValidationError.emailInvalid);
      expect(
        AuthValidators.email('missing@tld'),
        ValidationError.emailInvalid,
      );
      expect(
        AuthValidators.email('@nodomain.com'),
        ValidationError.emailInvalid,
      );
    });

    test('returns null for a valid address', () {
      expect(AuthValidators.email('driver@example.com'), isNull);
    });

    test('trims surrounding whitespace before validating', () {
      expect(AuthValidators.email('  driver@example.com  '), isNull);
    });
  });

  group('AuthValidators.password', () {
    test('returns passwordRequired when null or empty', () {
      expect(AuthValidators.password(null), ValidationError.passwordRequired);
      expect(AuthValidators.password(''), ValidationError.passwordRequired);
    });

    test('returns passwordMinLength when shorter than 8 characters', () {
      expect(AuthValidators.password('abc123'), ValidationError.passwordMinLength);
    });

    test('accepts exactly 8 characters', () {
      expect(AuthValidators.password('abc123xy'), isNull);
    });
  });

  group('AuthValidators.strongPassword', () {
    test('returns passwordRequired when null or empty', () {
      expect(
        AuthValidators.strongPassword(null),
        ValidationError.passwordRequired,
      );
      expect(
        AuthValidators.strongPassword(''),
        ValidationError.passwordRequired,
      );
    });

    test('requires lower, upper, digit and special characters', () {
      expect(
        AuthValidators.strongPassword('alllowercase1!'),
        ValidationError.passwordStrongRules,
      );
      expect(
        AuthValidators.strongPassword('ALLUPPERCASE1!'),
        ValidationError.passwordStrongRules,
      );
      expect(
        AuthValidators.strongPassword('NoDigitsHere!!'),
        ValidationError.passwordStrongRules,
      );
      expect(
        AuthValidators.strongPassword('NoSpecials123'),
        ValidationError.passwordStrongRules,
      );
    });

    test('returns null when every rule is satisfied', () {
      expect(AuthValidators.strongPassword('Passw0rd!'), isNull);
    });
  });

  group('AuthValidators.confirmPassword', () {
    test('returns confirmPasswordRequired when null or empty', () {
      expect(
        AuthValidators.confirmPassword(null, 'Passw0rd!'),
        ValidationError.confirmPasswordRequired,
      );
      expect(
        AuthValidators.confirmPassword('', 'Passw0rd!'),
        ValidationError.confirmPasswordRequired,
      );
    });

    test('returns confirmPasswordMismatch when values differ', () {
      expect(
        AuthValidators.confirmPassword('Passw0rd?', 'Passw0rd!'),
        ValidationError.confirmPasswordMismatch,
      );
    });

    test('returns null when values match exactly', () {
      expect(AuthValidators.confirmPassword('Passw0rd!', 'Passw0rd!'), isNull);
    });
  });

  group('AuthValidators.username', () {
    test('returns usernameRequired when null or blank', () {
      expect(AuthValidators.username(null), ValidationError.usernameRequired);
      expect(AuthValidators.username('  '), ValidationError.usernameRequired);
    });

    test('returns usernameMinLength when shorter than 3 characters', () {
      expect(AuthValidators.username('ab'), ValidationError.usernameMinLength);
    });

    test('returns null for 3 or more characters', () {
      expect(AuthValidators.username('abc'), isNull);
    });
  });

  group('AuthValidators.addressFields', () {
    test('returns fieldRequired when null or blank', () {
      expect(AuthValidators.addressFields(null), ValidationError.fieldRequired);
      expect(AuthValidators.addressFields('  '), ValidationError.fieldRequired);
    });

    test('returns fieldMinLength when shorter than 3 characters', () {
      expect(
        AuthValidators.addressFields('ab'),
        ValidationError.fieldMinLength,
      );
    });

    test('returns null for 3 or more characters', () {
      expect(AuthValidators.addressFields('Cairo'), isNull);
    });
  });

  group('AuthValidators.firstName', () {
    test('returns firstNameRequired when null or blank', () {
      expect(AuthValidators.firstName(null), ValidationError.firstNameRequired);
      expect(AuthValidators.firstName(' '), ValidationError.firstNameRequired);
    });

    test('returns firstNameOnlyLetters when non-letters are present', () {
      expect(
        AuthValidators.firstName('No3rah'),
        ValidationError.firstNameOnlyLetters,
      );
      expect(
        AuthValidators.firstName('A'),
        ValidationError.firstNameOnlyLetters,
      );
    });

    test('returns null for 2 to 30 letters', () {
      expect(AuthValidators.firstName('Nour'), isNull);
    });
  });

  group('AuthValidators.lastName', () {
    test('returns lastNameRequired when null or blank', () {
      expect(AuthValidators.lastName(null), ValidationError.lastNameRequired);
      expect(AuthValidators.lastName(' '), ValidationError.lastNameRequired);
    });

    test('returns lastNameOnlyLetters when non-letters are present', () {
      expect(
        AuthValidators.lastName('Mohamed7'),
        ValidationError.lastNameOnlyLetters,
      );
    });

    test('returns null for 2 to 30 letters', () {
      expect(AuthValidators.lastName('Mohamed'), isNull);
    });
  });

  group('AuthValidators.phone', () {
    test('returns phoneRequired when null or empty', () {
      expect(AuthValidators.phone(null), ValidationError.phoneRequired);
      expect(AuthValidators.phone(''), ValidationError.phoneRequired);
    });

    test('accepts valid prefixes 010, 011, 012 and 015', () {
      expect(AuthValidators.phone('01012345678'), isNull);
      expect(AuthValidators.phone('01112345678'), isNull);
      expect(AuthValidators.phone('01212345678'), isNull);
      expect(AuthValidators.phone('01512345678'), isNull);
    });

    test('returns phoneInvalid for unsupported prefixes or bad lengths', () {
      expect(AuthValidators.phone('01312345678'), ValidationError.phoneInvalid);
      expect(AuthValidators.phone('0101234'), ValidationError.phoneInvalid);
      expect(
        AuthValidators.phone('+201012345678'),
        ValidationError.phoneInvalid,
      );
    });
  });
}