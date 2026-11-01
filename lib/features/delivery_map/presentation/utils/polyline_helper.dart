import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract final class PolylineHelper {
  static const Color routeColor = Color(0xFFD21E6A);

  static List<LatLng> createRouteCoordinates(LatLng start, LatLng end) {
    // Generates a turn-based route path between driver and destination
    final midLat = start.latitude + (end.latitude - start.latitude) * 0.45;
    final midLng = start.longitude + (end.longitude - start.longitude) * 0.55;

    return <LatLng>[
      start,
      LatLng(midLat, start.longitude),
      LatLng(midLat, midLng),
      LatLng(end.latitude, midLng),
      end,
    ];
  }

  static Polyline buildRoutePolyline({
    required String id,
    required LatLng start,
    required LatLng end,
    Color color = routeColor,
    int width = 4,
  }) {
    return Polyline(
      polylineId: PolylineId(id),
      points: createRouteCoordinates(start, end),
      color: color,
      width: width,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
    );
  }
}
