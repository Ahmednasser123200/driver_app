// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForgotPasswordResponseDto _$ForgotPasswordResponseDtoFromJson(
  Map<String, dynamic> json,
) => ForgotPasswordResponseDto(
  data: json['data'] as String,
  message: json['message'] as String,
  errorCode: json['errorCode'] as String,
  isSuccess: json['isSuccess'] as bool? ?? false,
);

Map<String, dynamic> _$ForgotPasswordResponseDtoToJson(
  ForgotPasswordResponseDto instance,
) => <String, dynamic>{
  'data': instance.data,
  'message': instance.message,
  'errorCode': instance.errorCode,
  'isSuccess': instance.isSuccess,
};
