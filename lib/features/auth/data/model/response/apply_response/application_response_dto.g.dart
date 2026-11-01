// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplicationResponseDto _$ApplicationResponseDtoFromJson(
  Map<String, dynamic> json,
) => ApplicationResponseDto(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : ApplicationDto.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ApplicationResponseDtoToJson(
  ApplicationResponseDto instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
