import 'package:driver_app/features/pickup_location/domain/entities/map_location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

extension MapLocationLatLngExtension on MapLocation {
  LatLng toLatLng() => LatLng(latitude, longitude);
}

extension LatLngMapLocationExtension on LatLng {
  MapLocation toMapLocation() =>
      MapLocation(latitude: latitude, longitude: longitude);
}

/// Builds the bounding box that contains every given point.
LatLngBounds? buildRouteBounds(List<LatLng> points) {
  if (points.isEmpty) return null;

  var minLatitude = points.first.latitude;
  var maxLatitude = points.first.latitude;
  var minLongitude = points.first.longitude;
  var maxLongitude = points.first.longitude;

  for (final point in points.skip(1)) {
    if (point.latitude < minLatitude) minLatitude = point.latitude;
    if (point.latitude > maxLatitude) maxLatitude = point.latitude;
    if (point.longitude < minLongitude) minLongitude = point.longitude;
    if (point.longitude > maxLongitude) maxLongitude = point.longitude;
  }

  return LatLngBounds(
    southwest: LatLng(minLatitude, minLongitude),
    northeast: LatLng(maxLatitude, maxLongitude),
  );
}
