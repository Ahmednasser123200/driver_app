// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_driver_location_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportDriverLocationResponseDto _$ReportDriverLocationResponseDtoFromJson(
  Map<String, dynamic> json,
) => ReportDriverLocationResponseDto(
  success: json['success'] as bool,
  recordedAt: json['recordedAt'] as String,
);

Map<String, dynamic> _$ReportDriverLocationResponseDtoToJson(
  ReportDriverLocationResponseDto instance,
) => <String, dynamic>{
  'success': instance.success,
  'recordedAt': instance.recordedAt,
};
