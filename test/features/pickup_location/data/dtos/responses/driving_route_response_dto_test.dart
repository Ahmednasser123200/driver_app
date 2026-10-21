import 'package:driver_app/features/pickup_location/data/dtos/responses/driving_route_response_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures.dart';

void main() {
  group('DrivingRouteResponseDto', () {
    test(
      'maps the GeoJSON coordinates from [longitude, latitude] to domain',
      () {
        final dto = DrivingRouteResponseDto.fromJson(osrmRouteJson());

        expect(dto.isOk, isTrue);
        expect(dto.routeList, hasLength(1));

        final route = dto.routeList.first.toDomain();

        expect(route.points, hasLength(3));
        expect(route.points.first.latitude, 30.0444);
        expect(route.points.first.longitude, 31.2357);
        expect(route.points.last.latitude, 30.0398);
        expect(route.points.last.longitude, 31.2302);
        expect(route.distanceMeters, 1842.7);
        expect(route.durationSeconds, 312.4);
        expect(route.isEmpty, isFalse);
      },
    );

    test('is not ok when the service answers with another code', () {
      final dto = DrivingRouteResponseDto.fromJson(<String, dynamic>{
        'code': 'NoRoute',
        'message': 'No route found',
      });

      expect(dto.isOk, isFalse);
      expect(dto.routeList, isEmpty);
    });

    test('is not ok when the payload has no code at all', () {
      final dto = DrivingRouteResponseDto.fromJson(<String, dynamic>{});

      expect(dto.isOk, isFalse);
      expect(dto.routeList, isEmpty);
    });

    test('skips malformed coordinates', () {
      final dto = DrivingRouteResponseDto.fromJson(<String, dynamic>{
        'code': 'Ok',
        'routes': [
          <String, dynamic>{
            'distance': 100.0,
            'duration': 50.0,
            'geometry': <String, dynamic>{
              'type': 'LineString',
              'coordinates': [
                <double>[31.2357],
                <double>[31.2331, 30.0421],
              ],
            },
          },
        ],
      });

      final route = dto.routeList.first.toDomain();

      expect(route.points, hasLength(1));
      expect(route.points.single.latitude, 30.0421);
      expect(route.points.single.longitude, 31.2331);
    });

    test('builds an empty route when the geometry is missing', () {
      final dto = DrivingRouteResponseDto.fromJson(<String, dynamic>{
        'code': 'Ok',
        'routes': [
          <String, dynamic>{'distance': 100.0, 'duration': 50.0},
        ],
      });

      final route = dto.routeList.first.toDomain();

      expect(route.points, isEmpty);
      expect(route.isEmpty, isTrue);
    });

    test('throws when the payload does not match the contract', () {
      expect(
        () => DrivingRouteResponseDto.fromJson(<String, dynamic>{'code': 42}),
        throwsA(anything),
      );
    });
  });
}
