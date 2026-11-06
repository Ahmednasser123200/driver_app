import 'package:driver_app/features/delivery_map/domain/models/geo_point.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeoPoint', () {
    test('distanceTo returns 0 for identical coordinates', () {
      const point = GeoPoint(latitude: 30.0444, longitude: 31.2357);
      expect(point.distanceTo(point), 0.0);
    });

    test('distanceTo computes accurate Haversine distance in meters', () {
      const cairo = GeoPoint(latitude: 30.0444, longitude: 31.2357);
      const giza = GeoPoint(latitude: 30.0131, longitude: 31.2089);

      final distance = cairo.distanceTo(giza);
      expect(distance, greaterThan(3500.0));
      expect(distance, lessThan(6000.0));
    });

    test('equality, hashCode, and toString work properly', () {
      const a = GeoPoint(latitude: 30.0, longitude: 31.0);
      const b = GeoPoint(latitude: 30.0, longitude: 31.0);
      const c = GeoPoint(latitude: 30.1, longitude: 31.0);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
      expect(a.toString(), contains('GeoPoint(latitude: 30.0, longitude: 31.0)'));
    });
  });
}
