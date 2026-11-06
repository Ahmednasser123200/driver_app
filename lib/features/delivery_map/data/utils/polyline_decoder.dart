import 'package:driver_app/features/delivery_map/domain/models/geo_point.dart';

abstract final class PolylineDecoder {
  /// Decodes a Google-encoded polyline string into a list of [GeoPoint] coordinates.
  ///
  /// Uses the standard 5-decimal place precision (1e5) by default.
  static List<GeoPoint> decode(String encoded, {int precision = 5}) {
    if (encoded.isEmpty) {
      return const <GeoPoint>[];
    }

    final points = <GeoPoint>[];
    final factor = precision == 6 ? 1e6 : 1e5;

    int index = 0;
    final len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      // Decode latitude
      int b;
      int shift = 0;
      int result = 0;
      do {
        if (index >= len) break;
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      // Decode longitude
      shift = 0;
      result = 0;
      do {
        if (index >= len) break;
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(GeoPoint(latitude: lat / factor, longitude: lng / factor));
    }

    return points;
  }
}
