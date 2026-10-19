import 'package:driver_app/features/order_details/domain/utils/phone_number.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneNumber.normalize', () {
    test('keeps a plain E.164 number', () {
      expect(PhoneNumber.normalize('+201001234567'), '+201001234567');
    });

    test('strips separators', () {
      expect(PhoneNumber.normalize('+20 100-123-4567'), '+201001234567');
    });

    test('converts the 00 international prefix', () {
      expect(PhoneNumber.normalize('00201001234567'), '+201001234567');
    });

    test('rejects a number without a country code', () {
      expect(PhoneNumber.normalize('01001234567'), isNull);
    });

    test('rejects an empty or whitespace value', () {
      expect(PhoneNumber.normalize(''), isNull);
      expect(PhoneNumber.normalize('   '), isNull);
    });

    test('rejects numbers outside the plausible length range', () {
      expect(PhoneNumber.normalize('+1234567'), isNull); // 7 digits
      expect(PhoneNumber.normalize('+1234567890123456'), isNull); // 16 digits
      expect(PhoneNumber.normalize('+12345678'), '+12345678'); // 8 digits
      expect(PhoneNumber.normalize('+123456789012345'), '+123456789012345');
    });
  });

  group('PhoneNumber.digitsOnly', () {
    test('drops the leading plus', () {
      expect(PhoneNumber.digitsOnly('+201001234567'), '201001234567');
    });

    test('is null when the number cannot be normalized', () {
      expect(PhoneNumber.digitsOnly('01001234567'), isNull);
    });
  });
}
