import 'package:driver_app/features/delivery_map/presentation/utils/polyline_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('PolylineHelper', () {
    test('createRouteCoordinates generates 5 waypoints between start and end', () {
      const start = LatLng(30.0, 31.0);
      const end = LatLng(30.1, 31.1);

      final coordinates = PolylineHelper.createRouteCoordinates(start, end);

      expect(coordinates.length, 5);
      expect(coordinates.first, start);
      expect(coordinates.last, end);
    });

    test('buildRoutePolyline constructs a Polyline with expected attributes', () {
      const start = LatLng(30.0, 31.0);
      const end = LatLng(30.1, 31.1);

      final polyline = PolylineHelper.buildRoutePolyline(
        id: 'test_route',
        start: start,
        end: end,
        color: Colors.pink,
        width: 6,
      );

      expect(polyline.polylineId.value, 'test_route');
      expect(polyline.points.length, 5);
      expect(polyline.color, Colors.pink);
      expect(polyline.width, 6);
      expect(polyline.startCap, Cap.roundCap);
      expect(polyline.endCap, Cap.roundCap);
      expect(polyline.jointType, JointType.round);
    });
  });
}
