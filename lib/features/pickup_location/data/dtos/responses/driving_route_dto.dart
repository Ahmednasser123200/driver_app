import 'package:driver_app/features/pickup_location/domain/entities/driving_route.dart';
import 'package:json_annotation/json_annotation.dart';

import 'route_geometry_dto.dart';

part 'driving_route_dto.g.dart';

@JsonSerializable()
class DrivingRouteDto {
  const DrivingRouteDto({this.distance, this.duration, this.geometry});

  @JsonKey(name: 'distance')
  final double? distance;

  @JsonKey(name: 'duration')
  final double? duration;

  @JsonKey(name: 'geometry')
  final RouteGeometryDto? geometry;

  factory DrivingRouteDto.fromJson(Map<String, dynamic> json) =>
      _$DrivingRouteDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DrivingRouteDtoToJson(this);

  DrivingRoute toDomain() => DrivingRoute(
    points: geometry?.toDomainPoints() ?? const [],
    distanceMeters: distance ?? 0,
    durationSeconds: duration ?? 0,
  );
}
