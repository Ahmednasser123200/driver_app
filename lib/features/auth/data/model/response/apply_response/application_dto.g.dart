// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplicationDto _$ApplicationDtoFromJson(Map<String, dynamic> json) =>
    ApplicationDto(
      applicationId: json['applicationId'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$ApplicationDtoToJson(ApplicationDto instance) =>
    <String, dynamic>{
      'applicationId': instance.applicationId,
      'status': instance.status,
    };
