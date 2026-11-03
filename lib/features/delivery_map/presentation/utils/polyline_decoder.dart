import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract final class PolylineDecoder {
  /// Decodes a Google-encoded polyline string into a list of [LatLng] coordinates.
  ///
  /// Uses the standard 5-decimal place precision (1e5) by default.
  static List<LatLng> decode(String encoded, {int precision = 5}) {
    if (encoded.isEmpty) {
      return const <LatLng>[];
    }

    final points = <LatLng>[];
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

      points.add(LatLng(lat / factor, lng / factor));
    }

    return points;
  }
}
