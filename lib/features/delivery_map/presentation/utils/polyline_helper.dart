import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract final class PolylineHelper {
  static const Color routeColor = Color(0xFFD21E6A);
  static const int defaultWidth = 5;

  /// Calculates the geodesic distance between two points in meters using the Haversine formula.
  static double calculateHaversineDistance(LatLng a, LatLng b) {
    const earthRadiusMeters = 6371000.0;
    final dLat = (b.latitude - a.latitude) * (pi / 180.0);
    final dLng = (b.longitude - a.longitude) * (pi / 180.0);
    final lat1 = a.latitude * (pi / 180.0);
    final lat2 = b.latitude * (pi / 180.0);

    final sinDLat = sin(dLat / 2);
    final sinDLng = sin(dLng / 2);
    final h = sinDLat * sinDLat + cos(lat1) * cos(lat2) * sinDLng * sinDLng;
    final c = 2 * atan2(sqrt(h), sqrt(1 - h));
    return earthRadiusMeters * c;
  }

  /// Direct fallback coordinates between start and end.
  static List<LatLng> createRouteCoordinates(LatLng start, LatLng end) {
    return <LatLng>[start, end];
  }

  /// Builds a [Polyline] representing a road-routed delivery path with Material 3 styling.
  static Polyline buildRoutePolyline({
    required String id,
    List<LatLng>? points,
    LatLng? start,
    LatLng? end,
    Color color = routeColor,
    int width = defaultWidth,
  }) {
    final routePoints = points != null && points.isNotEmpty
        ? points
        : (start != null && end != null
            ? createRouteCoordinates(start, end)
            : const <LatLng>[]);

    return Polyline(
      polylineId: PolylineId(id),
      points: routePoints,
      color: color,
      width: width,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
    );
  }
}
