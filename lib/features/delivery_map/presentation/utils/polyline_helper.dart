import 'dart:math';

import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/delivery_map/domain/models/geo_point.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract final class PolylineHelper {
  static const Color routeColor = AppColors.primary;
  static const int defaultWidth = 5;

  /// Converts a domain [GeoPoint] into a Google Maps [LatLng].
  static LatLng toLatLng(GeoPoint point) =>
      LatLng(point.latitude, point.longitude);

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
    List<GeoPoint>? geoPoints,
    LatLng? start,
    LatLng? end,
    Color color = routeColor,
    int width = defaultWidth,
  }) {
    final resolvedPoints = points != null && points.isNotEmpty
        ? points
        : (geoPoints != null && geoPoints.isNotEmpty
              ? geoPoints.map(toLatLng).toList()
              : (start != null && end != null
                    ? createRouteCoordinates(start, end)
                    : const <LatLng>[]));

    return Polyline(
      polylineId: PolylineId(id),
      points: resolvedPoints,
      color: color,
      width: width,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
    );
  }
}
