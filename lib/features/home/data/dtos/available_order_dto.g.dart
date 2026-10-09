// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_order_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailableOrderDto _$AvailableOrderDtoFromJson(Map<String, dynamic> json) =>
    AvailableOrderDto(
      orderId: json['orderId'] as String,
      status: json['status'] as String,
      store: StoreDto.fromJson(json['store'] as Map<String, dynamic>),
      recipient: RecipientDto.fromJson(
        json['recipient'] as Map<String, dynamic>,
      ),
      itemCount: (json['itemCount'] as num).toInt(),
      total: (json['total'] as num).toDouble(),
      estimatedDeliveryAt: json['estimatedDeliveryAt'] == null
          ? null
          : DateTime.parse(json['estimatedDeliveryAt'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      assignedAt: json['assignedAt'] == null
          ? null
          : DateTime.parse(json['assignedAt'] as String),
    );

Map<String, dynamic> _$AvailableOrderDtoToJson(AvailableOrderDto instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'status': instance.status,
      'store': instance.store,
      'recipient': instance.recipient,
      'itemCount': instance.itemCount,
      'total': instance.total,
      'estimatedDeliveryAt': instance.estimatedDeliveryAt?.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'assignedAt': instance.assignedAt?.toIso8601String(),
    };
