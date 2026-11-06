import 'package:driver_app/features/delivery_map/domain/models/geo_point.dart';
import 'package:driver_app/features/delivery_map/presentation/utils/polyline_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('PolylineHelper', () {
    test('toLatLng maps GeoPoint to LatLng', () {
      const point = GeoPoint(latitude: 30.0444, longitude: 31.2357);
      expect(PolylineHelper.toLatLng(point), const LatLng(30.0444, 31.2357));
    });

    test('calculateHaversineDistance returns 0 for identical points', () {
      const p = LatLng(30.0444, 31.2357);
      final dist = PolylineHelper.calculateHaversineDistance(p, p);
      expect(dist, 0.0);
    });

    test('calculateHaversineDistance calculates accurate distance between distinct points', () {
      const cairo = LatLng(30.0444, 31.2357);
      const giza = LatLng(30.0131, 31.2089);
      final dist = PolylineHelper.calculateHaversineDistance(cairo, giza);

      expect(dist, greaterThan(3500.0));
      expect(dist, lessThan(6000.0));
    });

    test('buildRoutePolyline builds polyline from geoPoints', () {
      const geoPoints = <GeoPoint>[
        GeoPoint(latitude: 30.0, longitude: 31.0),
        GeoPoint(latitude: 30.1, longitude: 31.1),
      ];

      final polyline = PolylineHelper.buildRoutePolyline(
        id: 'geo_route',
        geoPoints: geoPoints,
        color: Colors.blue,
        width: 6,
      );

      expect(polyline.polylineId.value, 'geo_route');
      expect(
        polyline.points,
        const <LatLng>[LatLng(30.0, 31.0), LatLng(30.1, 31.1)],
      );
      expect(polyline.color, Colors.blue);
      expect(polyline.width, 6);
    });

    test('buildRoutePolyline falls back to start and end when points is null or empty', () {
      const start = LatLng(30.0, 31.0);
      const end = LatLng(30.1, 31.1);

      final polyline = PolylineHelper.buildRoutePolyline(
        id: 'fallback_route',
        start: start,
        end: end,
      );

      expect(polyline.polylineId.value, 'fallback_route');
      expect(polyline.points.length, 2);
      expect(polyline.points.first, start);
      expect(polyline.points.last, end);
      expect(polyline.color, PolylineHelper.routeColor);
      expect(polyline.width, PolylineHelper.defaultWidth);
    });

    test('buildRoutePolyline returns empty points when neither points nor start/end provided', () {
      final polyline = PolylineHelper.buildRoutePolyline(
        id: 'empty_route',
      );

      expect(polyline.points, isEmpty);
    });
  });
}
