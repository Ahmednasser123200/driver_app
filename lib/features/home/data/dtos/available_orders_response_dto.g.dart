// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_orders_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailableOrdersResponseDto _$AvailableOrdersResponseDtoFromJson(
  Map<String, dynamic> json,
) => AvailableOrdersResponseDto(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  data: AvailableOrdersDataDto.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AvailableOrdersResponseDtoToJson(
  AvailableOrdersResponseDto instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
