// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driving_route_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DrivingRouteDto _$DrivingRouteDtoFromJson(Map<String, dynamic> json) =>
    DrivingRouteDto(
      distance: (json['distance'] as num?)?.toDouble(),
      duration: (json['duration'] as num?)?.toDouble(),
      geometry: json['geometry'] == null
          ? null
          : RouteGeometryDto.fromJson(json['geometry'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DrivingRouteDtoToJson(DrivingRouteDto instance) =>
    <String, dynamic>{
      'distance': instance.distance,
      'duration': instance.duration,
      'geometry': instance.geometry,
    };
