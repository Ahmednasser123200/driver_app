// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_order_details_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverOrderDetailsDto _$DriverOrderDetailsDtoFromJson(
  Map<String, dynamic> json,
) => DriverOrderDetailsDto(
  orderId: json['orderId'] as String?,
  orderNumber: json['orderNumber'] as String?,
  status: DriverOrderDetailsDto._statusFromJson(json['status']),
  isGift: json['isGift'] as bool?,
  totalPrice: (json['totalPrice'] as num?)?.toDouble(),
  currency: json['currency'] as String?,
  paymentMethod: json['paymentMethod'] as String?,
  notes: json['notes'] as String?,
  pickupAddress: json['pickup'] == null
      ? null
      : PickupAddressDto.fromJson(json['pickup'] as Map<String, dynamic>),
  userAddress: json['userAddress'] == null
      ? null
      : UserAddressDto.fromJson(json['userAddress'] as Map<String, dynamic>),
  recipientInfo: json['recipientInfo'] == null
      ? null
      : RecipientInfoDto.fromJson(
          json['recipientInfo'] as Map<String, dynamic>,
        ),
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => OrderItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  timeline: (json['timeline'] as List<dynamic>?)
      ?.map((e) => TimelineDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DriverOrderDetailsDtoToJson(
  DriverOrderDetailsDto instance,
) => <String, dynamic>{
  'orderId': instance.orderId,
  'orderNumber': instance.orderNumber,
  'status': DriverOrderDetailsDto._statusToJson(instance.status),
  'isGift': instance.isGift,
  'totalPrice': instance.totalPrice,
  'currency': instance.currency,
  'paymentMethod': instance.paymentMethod,
  'notes': instance.notes,
  'pickup': instance.pickupAddress,
  'userAddress': instance.userAddress,
  'recipientInfo': instance.recipientInfo,
  'items': instance.items,
  'timeline': instance.timeline,
};
