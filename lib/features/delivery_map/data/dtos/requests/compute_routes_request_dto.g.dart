// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compute_routes_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComputeRoutesRequestDto _$ComputeRoutesRequestDtoFromJson(
  Map<String, dynamic> json,
) => ComputeRoutesRequestDto(
  origin: RouteWaypointDto.fromJson(json['origin'] as Map<String, dynamic>),
  destination: RouteWaypointDto.fromJson(
    json['destination'] as Map<String, dynamic>,
  ),
  travelMode: json['travelMode'] as String? ?? 'DRIVE',
);

Map<String, dynamic> _$ComputeRoutesRequestDtoToJson(
  ComputeRoutesRequestDto instance,
) => <String, dynamic>{
  'origin': instance.origin.toJson(),
  'destination': instance.destination.toJson(),
  'travelMode': instance.travelMode,
};

RouteWaypointDto _$RouteWaypointDtoFromJson(Map<String, dynamic> json) =>
    RouteWaypointDto(
      location: RouteLocationDto.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$RouteWaypointDtoToJson(RouteWaypointDto instance) =>
    <String, dynamic>{'location': instance.location.toJson()};

RouteLocationDto _$RouteLocationDtoFromJson(Map<String, dynamic> json) =>
    RouteLocationDto(
      latLng: RouteLatLngDto.fromJson(json['latLng'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RouteLocationDtoToJson(RouteLocationDto instance) =>
    <String, dynamic>{'latLng': instance.latLng.toJson()};

RouteLatLngDto _$RouteLatLngDtoFromJson(Map<String, dynamic> json) =>
    RouteLatLngDto(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$RouteLatLngDtoToJson(RouteLatLngDto instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
