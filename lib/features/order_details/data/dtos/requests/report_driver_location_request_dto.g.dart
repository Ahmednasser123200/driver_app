// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_driver_location_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportDriverLocationRequestDto _$ReportDriverLocationRequestDtoFromJson(
  Map<String, dynamic> json,
) => ReportDriverLocationRequestDto(
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  recordedAt: json['recordedAt'] as String,
);

Map<String, dynamic> _$ReportDriverLocationRequestDtoToJson(
  ReportDriverLocationRequestDto instance,
) => <String, dynamic>{
  'lat': instance.lat,
  'lng': instance.lng,
  'recordedAt': instance.recordedAt,
};
