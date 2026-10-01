// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_order_status_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateOrderStatusResponseDto _$UpdateOrderStatusResponseDtoFromJson(
  Map<String, dynamic> json,
) => UpdateOrderStatusResponseDto(
  orderId: json['orderId'] as String,
  status: json['status'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$UpdateOrderStatusResponseDtoToJson(
  UpdateOrderStatusResponseDto instance,
) => <String, dynamic>{
  'orderId': instance.orderId,
  'status': instance.status,
  'updatedAt': instance.updatedAt,
};
