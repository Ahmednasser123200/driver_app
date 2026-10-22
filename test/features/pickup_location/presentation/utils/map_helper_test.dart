import 'package:driver_app/features/pickup_location/domain/entities/map_location.dart';
import 'package:driver_app/features/pickup_location/presentation/utils/map_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('MapLocationLatLngExtension.toLatLng', () {
    test('maps the latitude and the longitude in the right order', () {
      final latLng = const MapLocation(
        latitude: 30.0444,
        longitude: 31.2357,
      ).toLatLng();

      expect(latLng.latitude, 30.0444);
      expect(latLng.longitude, 31.2357);
    });
  });

  group('LatLngMapLocationExtension.toMapLocation', () {
    test('maps the latitude and the longitude in the right order', () {
      final location = const LatLng(30.0444, 31.2357).toMapLocation();

      expect(location.latitude, 30.0444);
      expect(location.longitude, 31.2357);
    });
  });

  group('resolvePickupLocation', () {
    test('returns the pickup coordinates of the order', () {
      final location = resolvePickupLocation(
        buildDriverOrderDetailsEntity(),
        fallback: const LatLng(0, 0),
      );

      expect(location.latitude, 30.0511);
      expect(location.longitude, 31.3656);
    });

    test('returns the fallback when the order details are not loaded', () {
      final location = resolvePickupLocation(
        null,
        fallback: const LatLng(30.0444, 31.2357),
      );

      expect(location, const LatLng(30.0444, 31.2357));
    });
  });

  group('resolveCustomerLocation', () {
    test('returns the customer coordinates of the order', () {
      final location = resolveCustomerLocation(
        buildDriverOrderDetailsEntity(),
        fallback: const LatLng(0, 0),
      );

      expect(location.latitude, 30.0444);
      expect(location.longitude, 31.2357);
    });

    test('returns the fallback when the order details are not loaded', () {
      final location = resolveCustomerLocation(
        null,
        fallback: const LatLng(30.0398, 31.2302),
      );

      expect(location, const LatLng(30.0398, 31.2302));
    });
  });

  group('buildRouteBounds', () {
    test('returns null when there is no point', () {
      expect(buildRouteBounds(const []), isNull);
    });

    test('builds the box that contains every point', () {
      final bounds = buildRouteBounds(const [
        LatLng(30.0444, 31.2357),
        LatLng(30.0398, 31.2302),
        LatLng(30.0500, 31.2400),
      ]);

      expect(bounds, isNotNull);
      expect(bounds!.southwest.latitude, 30.0398);
      expect(bounds.southwest.longitude, 31.2302);
      expect(bounds.northeast.latitude, 30.0500);
      expect(bounds.northeast.longitude, 31.2400);
    });

    test('builds a single point box when every point is the same', () {
      final bounds = buildRouteBounds(const [
        LatLng(30.0444, 31.2357),
        LatLng(30.0444, 31.2357),
      ]);

      expect(bounds!.southwest, const LatLng(30.0444, 31.2357));
      expect(bounds.northeast, const LatLng(30.0444, 31.2357));
    });
  });
}
