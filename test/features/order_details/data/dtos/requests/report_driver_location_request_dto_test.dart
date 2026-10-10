import 'package:driver_app/features/order_details/data/dtos/requests/report_driver_location_request_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ReportDriverLocationRequestDto build() => ReportDriverLocationRequestDto(
    lat: 30.0444,
    lng: 31.2357,
    recordedAt: '2026-09-19T18:00:00Z',
  );

  group('toJson', () {
    test('serialises lat, lng and recordedAt', () {
      expect(build().toJson(), {
        'lat': 30.0444,
        'lng': 31.2357,
        'recordedAt': '2026-09-19T18:00:00Z',
      });
    });

    test('uses the short lat/lng keys rather than latitude/longitude', () {
      final json = build().toJson();

      expect(json.keys.toSet(), {'lat', 'lng', 'recordedAt'});
      expect(json.containsKey('latitude'), isFalse);
      expect(json.containsKey('longitude'), isFalse);
    });

    test('does not send an orderId', () {
      expect(build().toJson().containsKey('orderId'), isFalse);
    });

    test('keeps zero coordinates', () {
      final json = ReportDriverLocationRequestDto(
        lat: 0,
        lng: 0,
        recordedAt: 'ts',
      ).toJson();

      expect(json['lat'], 0.0);
      expect(json['lng'], 0.0);
    });

    test('keeps negative coordinates', () {
      final json = ReportDriverLocationRequestDto(
        lat: -33.8688,
        lng: -151.2093,
        recordedAt: 'ts',
      ).toJson();

      expect(json['lat'], -33.8688);
      expect(json['lng'], -151.2093);
    });
  });

  group('fromJson', () {
    test('parses all fields', () {
      final dto = ReportDriverLocationRequestDto.fromJson(build().toJson());

      expect(dto.lat, 30.0444);
      expect(dto.lng, 31.2357);
      expect(dto.recordedAt, '2026-09-19T18:00:00Z');
    });

    test('coerces integer coordinates into doubles', () {
      final dto = ReportDriverLocationRequestDto.fromJson({
        'lat': 30,
        'lng': 31,
        'recordedAt': 'ts',
      });

      expect(dto.lat, 30.0);
      expect(dto.lng, 31.0);
    });

    test('round-trips through toJson', () {
      final original = build();

      expect(
        ReportDriverLocationRequestDto.fromJson(original.toJson()).toJson(),
        original.toJson(),
      );
    });
  });
}