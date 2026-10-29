// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_geometry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteGeometryDto _$RouteGeometryDtoFromJson(Map<String, dynamic> json) =>
    RouteGeometryDto(
      type: json['type'] as String?,
      coordinates: (json['coordinates'] as List<dynamic>?)
          ?.map(
            (e) =>
                (e as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
          )
          .toList(),
    );

Map<String, dynamic> _$RouteGeometryDtoToJson(RouteGeometryDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
    };
