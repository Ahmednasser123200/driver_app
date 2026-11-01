// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reset_password_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResetPasswordResponseDto _$ResetPasswordResponseDtoFromJson(
  Map<String, dynamic> json,
) => ResetPasswordResponseDto(
  data: json['data'] as String,
  message: json['message'] as String,
  errorCode: json['errorCode'] as String,
  isSuccess: json['isSuccess'] as bool? ?? false,
);

Map<String, dynamic> _$ResetPasswordResponseDtoToJson(
  ResetPasswordResponseDto instance,
) => <String, dynamic>{
  'data': instance.data,
  'message': instance.message,
  'errorCode': instance.errorCode,
  'isSuccess': instance.isSuccess,
};
