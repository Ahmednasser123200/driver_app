// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driving_route_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DrivingRouteResponseDto _$DrivingRouteResponseDtoFromJson(
  Map<String, dynamic> json,
) => DrivingRouteResponseDto(
  code: json['code'] as String?,
  routes: (json['routes'] as List<dynamic>?)
      ?.map((e) => DrivingRouteDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  message: json['message'] as String?,
);

Map<String, dynamic> _$DrivingRouteResponseDtoToJson(
  DrivingRouteResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'routes': instance.routes,
  'message': instance.message,
};
