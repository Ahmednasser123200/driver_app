// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compute_routes_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComputeRoutesResponseDto _$ComputeRoutesResponseDtoFromJson(
  Map<String, dynamic> json,
) => ComputeRoutesResponseDto(
  routes: (json['routes'] as List<dynamic>?)
      ?.map((e) => ComputedRouteDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ComputeRoutesResponseDtoToJson(
  ComputeRoutesResponseDto instance,
) => <String, dynamic>{
  'routes': instance.routes?.map((e) => e.toJson()).toList(),
};

ComputedRouteDto _$ComputedRouteDtoFromJson(Map<String, dynamic> json) =>
    ComputedRouteDto(
      distanceMeters: json['distanceMeters'] as num?,
      duration: json['duration'] as String?,
      polyline: json['polyline'] == null
          ? null
          : RoutePolylineDto.fromJson(json['polyline'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ComputedRouteDtoToJson(ComputedRouteDto instance) =>
    <String, dynamic>{
      'distanceMeters': instance.distanceMeters,
      'duration': instance.duration,
      'polyline': instance.polyline?.toJson(),
    };

RoutePolylineDto _$RoutePolylineDtoFromJson(Map<String, dynamic> json) =>
    RoutePolylineDto(encodedPolyline: json['encodedPolyline'] as String?);

Map<String, dynamic> _$RoutePolylineDtoToJson(RoutePolylineDto instance) =>
    <String, dynamic>{'encodedPolyline': instance.encodedPolyline};
