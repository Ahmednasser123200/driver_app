import 'dart:math';

import 'package:equatable/equatable.dart';

class GeoPoint extends Equatable {
  final double latitude;
  final double longitude;

  const GeoPoint({
    required this.latitude,
    required this.longitude,
  });

  /// Calculates the geodesic distance to [other] in meters using the Haversine formula.
  double distanceTo(GeoPoint other) {
    const earthRadiusMeters = 6371000.0;
    final dLat = (other.latitude - latitude) * (pi / 180.0);
    final dLng = (other.longitude - longitude) * (pi / 180.0);
    final lat1 = latitude * (pi / 180.0);
    final lat2 = other.latitude * (pi / 180.0);

    final sinDLat = sin(dLat / 2);
    final sinDLng = sin(dLng / 2);
    final h = sinDLat * sinDLat + cos(lat1) * cos(lat2) * sinDLng * sinDLng;
    final c = 2 * atan2(sqrt(h), sqrt(1 - h));
    return earthRadiusMeters * c;
  }

  @override
  List<Object?> get props => [latitude, longitude];

  @override
  String toString() => 'GeoPoint(latitude: $latitude, longitude: $longitude)';
}
