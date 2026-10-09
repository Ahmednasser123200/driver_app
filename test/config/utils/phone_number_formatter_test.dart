import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/config/utils/phone_number_formatter.dart';

void main() {
  group('PhoneNumberFormatter - stripLeadingTrunkZero', () {
    test('strips leading 0 when phone number starts with 0', () {
      expect(
        PhoneNumberFormatter.stripLeadingTrunkZero('01234567890'),
        '1234567890',
      );
      expect(
        PhoneNumberFormatter.stripLeadingTrunkZero('01012345678'),
        '1012345678',
      );
      expect(
        PhoneNumberFormatter.stripLeadingTrunkZero('01123456789'),
        '1123456789',
      );
    });

    test('returns original string when phone number does not start with 0', () {
      expect(
        PhoneNumberFormatter.stripLeadingTrunkZero('1012345678'),
        '1012345678',
      );
      expect(
        PhoneNumberFormatter.stripLeadingTrunkZero('+201012345678'),
        '+201012345678',
      );
    });

    test('handles empty string properly', () {
      expect(PhoneNumberFormatter.stripLeadingTrunkZero(''), '');
    });

    test('handles single character 0 properly', () {
      expect(PhoneNumberFormatter.stripLeadingTrunkZero('0'), '');
    });
  });
}
