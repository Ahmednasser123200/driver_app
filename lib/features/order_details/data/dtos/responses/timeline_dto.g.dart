// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelineDto _$TimelineDtoFromJson(Map<String, dynamic> json) => TimelineDto(
  status: json['status'] as String,
  timestamp: json['timestamp'] as String,
);

Map<String, dynamic> _$TimelineDtoToJson(TimelineDto instance) =>
    <String, dynamic>{
      'status': instance.status,
      'timestamp': instance.timestamp,
    };
