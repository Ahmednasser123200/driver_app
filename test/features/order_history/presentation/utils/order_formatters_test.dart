import 'package:driver_app/features/order_history/presentation/utils/order_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('order_formatters', () {
    test('shortOrderId leaves 6 or fewer chars unchanged, truncates longer to 6', () {
      expect(shortOrderId('12345'), '12345');
      expect(shortOrderId('123456'), '123456');
      expect(shortOrderId('123456789'), '123456');
    });

    test('formatOrderId prepends "# "', () {
      expect(formatOrderId('12345678'), '# 123456');
    });

    test('formatQuantity prepends "X"', () {
      expect(formatQuantity(1), 'X1');
      expect(formatQuantity(5), 'X5');
    });

    test('formatPrice formats whole numbers without decimals and fractional numbers with 2 decimals', () {
      expect(formatPrice(100.0, 'EGP'), 'EGP 100');
      expect(formatPrice(99.99, 'USD'), 'USD 99.99');
      expect(formatPrice(50.5, 'EUR'), 'EUR 50.50');
    });
  });
}
