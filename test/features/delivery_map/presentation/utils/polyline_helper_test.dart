import 'package:driver_app/features/delivery_map/presentation/utils/polyline_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('PolylineHelper', () {
    test('calculateHaversineDistance returns 0 for identical points', () {
      const p = LatLng(30.0444, 31.2357);
      final dist = PolylineHelper.calculateHaversineDistance(p, p);
      expect(dist, 0.0);
    });

    test('calculateHaversineDistance calculates accurate distance between distinct points', () {
      const cairo = LatLng(30.0444, 31.2357);
      const giza = LatLng(30.0131, 31.2089);
      final dist = PolylineHelper.calculateHaversineDistance(cairo, giza);

      // Distance between Cairo and Giza centers is roughly 4-5 km
      expect(dist, greaterThan(3500.0));
      expect(dist, lessThan(6000.0));
    });

    test('createRouteCoordinates returns direct start and end points', () {
      const start = LatLng(30.0, 31.0);
      const end = LatLng(30.1, 31.1);

      final coordinates = PolylineHelper.createRouteCoordinates(start, end);

      expect(coordinates.length, 2);
      expect(coordinates.first, start);
      expect(coordinates.last, end);
    });

    test('buildRoutePolyline builds polyline with provided road coordinates', () {
      const roadPoints = <LatLng>[
        LatLng(30.0, 31.0),
        LatLng(30.05, 31.05),
        LatLng(30.1, 31.1),
      ];

      final polyline = PolylineHelper.buildRoutePolyline(
        id: 'road_route',
        points: roadPoints,
        color: Colors.blue,
        width: 6,
      );

      expect(polyline.polylineId.value, 'road_route');
      expect(polyline.points, roadPoints);
      expect(polyline.color, Colors.blue);
      expect(polyline.width, 6);
      expect(polyline.startCap, Cap.roundCap);
      expect(polyline.endCap, Cap.roundCap);
      expect(polyline.jointType, JointType.round);
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
