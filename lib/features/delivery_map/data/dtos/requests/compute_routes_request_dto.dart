import 'package:driver_app/features/delivery_map/domain/models/geo_point.dart';
import 'package:json_annotation/json_annotation.dart';

part 'compute_routes_request_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class ComputeRoutesRequestDto {
  @JsonKey(name: 'origin')
  final RouteWaypointDto origin;

  @JsonKey(name: 'destination')
  final RouteWaypointDto destination;

  @JsonKey(name: 'travelMode')
  final String travelMode;

  const ComputeRoutesRequestDto({
    required this.origin,
    required this.destination,
    this.travelMode = 'DRIVE',
  });

  factory ComputeRoutesRequestDto.fromCoordinates({
    required GeoPoint origin,
    required GeoPoint destination,
    String travelMode = 'DRIVE',
  }) {
    return ComputeRoutesRequestDto(
      origin: RouteWaypointDto.fromGeoPoint(origin),
      destination: RouteWaypointDto.fromGeoPoint(destination),
      travelMode: travelMode,
    );
  }

  factory ComputeRoutesRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ComputeRoutesRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ComputeRoutesRequestDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RouteWaypointDto {
  @JsonKey(name: 'location')
  final RouteLocationDto location;

  const RouteWaypointDto({required this.location});

  factory RouteWaypointDto.fromGeoPoint(GeoPoint point) {
    return RouteWaypointDto(
      location: RouteLocationDto(
        latLng: RouteLatLngDto(
          latitude: point.latitude,
          longitude: point.longitude,
        ),
      ),
    );
  }

  factory RouteWaypointDto.fromJson(Map<String, dynamic> json) =>
      _$RouteWaypointDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RouteWaypointDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RouteLocationDto {
  @JsonKey(name: 'latLng')
  final RouteLatLngDto latLng;

  const RouteLocationDto({required this.latLng});

  factory RouteLocationDto.fromJson(Map<String, dynamic> json) =>
      _$RouteLocationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RouteLocationDtoToJson(this);
}

@JsonSerializable()
class RouteLatLngDto {
  @JsonKey(name: 'latitude')
  final double latitude;

  @JsonKey(name: 'longitude')
  final double longitude;

  const RouteLatLngDto({
    required this.latitude,
    required this.longitude,
  });

  factory RouteLatLngDto.fromJson(Map<String, dynamic> json) =>
      _$RouteLatLngDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RouteLatLngDtoToJson(this);
}
