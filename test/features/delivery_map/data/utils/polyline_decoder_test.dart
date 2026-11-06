import 'package:driver_app/features/delivery_map/data/utils/polyline_decoder.dart';
import 'package:driver_app/features/delivery_map/domain/models/geo_point.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PolylineDecoder', () {
    test('decode returns empty list when given an empty string', () {
      final points = PolylineDecoder.decode('');
      expect(points, isEmpty);
    });

    test('decode correctly decodes a single coordinate pair', () {
      // _p~iF~ps|U encodes: (38.5, -120.2)
      final points = PolylineDecoder.decode('_p~iF~ps|U');
      expect(points.length, 1);
      expect(points.first.latitude, closeTo(38.5, 0.0001));
      expect(points.first.longitude, closeTo(-120.2, 0.0001));
    });

    test('decode correctly decodes standard Google polyline test vector', () {
      const encoded = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';
      final points = PolylineDecoder.decode(encoded);

      expect(points.length, 3);
      expect(points[0].latitude, closeTo(38.5, 0.0001));
      expect(points[0].longitude, closeTo(-120.2, 0.0001));
      expect(points[1].latitude, closeTo(40.7, 0.0001));
      expect(points[1].longitude, closeTo(-120.95, 0.0001));
      expect(points[2].latitude, closeTo(43.252, 0.0001));
      expect(points[2].longitude, closeTo(-126.453, 0.0001));
    });

    test('decode supports precision 6 decoding', () {
      final points = PolylineDecoder.decode('_p~iF~ps|U', precision: 6);
      expect(points.length, 1);
      expect(points.first.latitude, closeTo(3.85, 0.0001));
      expect(points.first.longitude, closeTo(-12.02, 0.0001));
    });

    test('decode handles malformed or incomplete strings gracefully', () {
      final points = PolylineDecoder.decode('_p~');
      expect(points, isA<List<GeoPoint>>());
    });
  });
}
