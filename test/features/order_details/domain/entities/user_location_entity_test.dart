import 'package:driver_app/features/order_details/domain/entities/user_location_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserLocationEntity', () {
    final now = DateTime(2026, 10, 27, 12, 0, 0);

    test('supports value equality and hashCode', () {
      final loc1 = UserLocationEntity(
        latitude: 30.0444,
        longitude: 31.2357,
        timestamp: now,
        accuracy: 5.0,
        altitude: 10.0,
        speed: 1.5,
        heading: 90.0,
      );

      final loc2 = UserLocationEntity(
        latitude: 30.0444,
        longitude: 31.2357,
        timestamp: now,
        accuracy: 5.0,
        altitude: 10.0,
        speed: 1.5,
        heading: 90.0,
      );

      final loc3 = UserLocationEntity(
        latitude: 31.0,
        longitude: 31.2357,
        timestamp: now,
      );

      expect(loc1, equals(loc2));
      expect(loc1.hashCode, equals(loc2.hashCode));
      expect(loc1, isNot(equals(loc3)));
    });

    test('toString contains all field values', () {
      final loc = UserLocationEntity(
        latitude: 30.0444,
        longitude: 31.2357,
        timestamp: now,
      );

      expect(loc.toString(), contains('30.0444'));
      expect(loc.toString(), contains('31.2357'));
    });
  });
}
