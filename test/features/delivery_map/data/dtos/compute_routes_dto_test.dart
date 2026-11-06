import 'package:driver_app/features/delivery_map/data/dtos/requests/compute_routes_request_dto.dart';
import 'package:driver_app/features/delivery_map/data/dtos/responses/compute_routes_response_dto.dart';
import 'package:driver_app/features/delivery_map/domain/models/geo_point.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComputeRoutesRequestDto', () {
    test('fromCoordinates serializes and deserializes accurately', () {
      const origin = GeoPoint(latitude: 30.0190, longitude: 31.2140);
      const destination = GeoPoint(latitude: 30.0250, longitude: 31.2200);

      final dto = ComputeRoutesRequestDto.fromCoordinates(
        origin: origin,
        destination: destination,
      );
      final json = dto.toJson();
      final roundTrip = ComputeRoutesRequestDto.fromJson(json);

      expect(roundTrip.travelMode, 'DRIVE');
      expect(roundTrip.origin.location.latLng.latitude, 30.0190);
      expect(roundTrip.origin.location.latLng.longitude, 31.2140);
      expect(roundTrip.destination.location.latLng.latitude, 30.0250);
      expect(roundTrip.destination.location.latLng.longitude, 31.2200);
    });
  });

  group('ComputeRoutesResponseDto', () {
    test('fromJson and toDomain decode polyline into RouteModel', () {
      final json = <String, dynamic>{
        'routes': [
          <String, dynamic>{
            'distanceMeters': 3500,
            'duration': '420s',
            'polyline': <String, dynamic>{
              'encodedPolyline': '_p~iF~ps|U_ulLnnqC',
            },
          },
        ],
      };

      final dto = ComputeRoutesResponseDto.fromJson(json);
      final serialized = dto.toJson();
      expect(serialized['routes'], isNotEmpty);

      final domain = dto.toDomain();
      expect(domain, isNotNull);
      expect(domain!.distanceMeters, 3500.0);
      expect(domain.durationSeconds, 420.0);
      expect(domain.points.length, 2);
      expect(domain.encodedPolyline, '_p~iF~ps|U_ulLnnqC');
    });

    test('toDomain returns null when routes or polyline are missing', () {
      const emptyDto = ComputeRoutesResponseDto(routes: []);
      expect(emptyDto.toDomain(), isNull);

      const noPolylineDto = ComputeRoutesResponseDto(
        routes: [ComputedRouteDto(distanceMeters: 100, duration: '10s')],
      );
      expect(noPolylineDto.toDomain(), isNull);
    });
  });
}
