import 'package:driver_app/features/pickup_location/data/dtos/responses/driving_route_response_dto.dart';
import 'package:driver_app/features/pickup_location/domain/entities/driving_route.dart';
import 'package:driver_app/features/pickup_location/domain/entities/map_location.dart';
import 'package:driver_app/features/pickup_location/domain/params/driving_route_params.dart';

const MapLocation kPickupLocation = MapLocation(
  latitude: 30.0444,
  longitude: 31.2357,
);

const MapLocation kCustomerLocation = MapLocation(
  latitude: 30.0398,
  longitude: 31.2302,
);

const DrivingRouteParams kDrivingRouteParams = DrivingRouteParams(
  origin: kPickupLocation,
  destination: kCustomerLocation,
);

/// The payload returned by the routing service for a successful request.
Map<String, dynamic> osrmRouteJson() => <String, dynamic>{
  'code': 'Ok',
  'routes': [
    <String, dynamic>{
      'distance': 1842.7,
      'duration': 312.4,
      'geometry': <String, dynamic>{
        'type': 'LineString',
        'coordinates': [
          <double>[31.2357, 30.0444],
          <double>[31.2331, 30.0421],
          <double>[31.2302, 30.0398],
        ],
      },
    },
  ],
};

DrivingRouteResponseDto buildDrivingRouteResponseDto() =>
    DrivingRouteResponseDto.fromJson(osrmRouteJson());

DrivingRoute buildDrivingRoute() => DrivingRoute(
  points: const [
    MapLocation(latitude: 30.0444, longitude: 31.2357),
    MapLocation(latitude: 30.0421, longitude: 31.2331),
    MapLocation(latitude: 30.0398, longitude: 31.2302),
  ],
  distanceMeters: 1842.7,
  durationSeconds: 312.4,
);
