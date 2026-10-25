import 'package:driver_app/features/pickup_location/domain/entities/map_location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MapLocation.isValid', () {
    test('accepts a coordinate inside the valid ranges', () {
      expect(
        const MapLocation(latitude: 30.0444, longitude: 31.2357).isValid,
        isTrue,
      );
    });

    test('accepts the boundaries of the valid ranges', () {
      expect(const MapLocation(latitude: 90, longitude: 180).isValid, isTrue);
      expect(const MapLocation(latitude: -90, longitude: -180).isValid, isTrue);
    });

    test('rejects a latitude outside the -90..90 range', () {
      expect(
        const MapLocation(latitude: 90.5, longitude: 31.2357).isValid,
        isFalse,
      );
      expect(
        const MapLocation(latitude: -91, longitude: 31.2357).isValid,
        isFalse,
      );
    });

    test('rejects a longitude outside the -180..180 range', () {
      expect(
        const MapLocation(latitude: 30.0444, longitude: 180.5).isValid,
        isFalse,
      );
      expect(
        const MapLocation(latitude: 30.0444, longitude: -181).isValid,
        isFalse,
      );
    });

    test('rejects the null island (0, 0)', () {
      const location = MapLocation(latitude: 0, longitude: 0);

      expect(location.isNullIsland, isTrue);
      expect(location.isValid, isFalse);
    });

    test('keeps a zero latitude with a real longitude valid', () {
      expect(
        const MapLocation(latitude: 0, longitude: 31.2357).isValid,
        isTrue,
      );
    });
  });
}
