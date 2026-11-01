// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_details_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderDetailsResponseDto _$OrderDetailsResponseDtoFromJson(
  Map<String, dynamic> json,
) => OrderDetailsResponseDto(
  orderId: json['orderId'] as String,
  status: json['status'] as String,
  isGift: json['isGift'] as bool,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderDetailsItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  pickup: OrderPickupDto.fromJson(json['pickup'] as Map<String, dynamic>),
  userAddress: OrderUserAddressDto.fromJson(
    json['userAddress'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$OrderDetailsResponseDtoToJson(
  OrderDetailsResponseDto instance,
) => <String, dynamic>{
  'orderId': instance.orderId,
  'status': instance.status,
  'isGift': instance.isGift,
  'items': instance.items,
  'pickup': instance.pickup,
  'userAddress': instance.userAddress,
};

OrderDetailsItemDto _$OrderDetailsItemDtoFromJson(Map<String, dynamic> json) =>
    OrderDetailsItemDto(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$OrderDetailsItemDtoToJson(
  OrderDetailsItemDto instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'productName': instance.productName,
  'quantity': instance.quantity,
};

LocationDto _$LocationDtoFromJson(Map<String, dynamic> json) => LocationDto(
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
);

Map<String, dynamic> _$LocationDtoToJson(LocationDto instance) =>
    <String, dynamic>{'lat': instance.lat, 'lng': instance.lng};

OrderPickupDto _$OrderPickupDtoFromJson(Map<String, dynamic> json) =>
    OrderPickupDto(
      storeName: json['storeName'] as String,
      location: LocationDto.fromJson(json['location'] as Map<String, dynamic>),
      address: json['address'] as String,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$OrderPickupDtoToJson(OrderPickupDto instance) =>
    <String, dynamic>{
      'storeName': instance.storeName,
      'location': instance.location,
      'address': instance.address,
      'imageUrl': instance.imageUrl,
    };

OrderUserAddressDto _$OrderUserAddressDtoFromJson(Map<String, dynamic> json) =>
    OrderUserAddressDto(
      recipientName: json['recipientName'] as String,
      recipientPhone: json['recipientPhone'] as String,
      location: LocationDto.fromJson(json['location'] as Map<String, dynamic>),
      address: json['address'] as String,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$OrderUserAddressDtoToJson(
  OrderUserAddressDto instance,
) => <String, dynamic>{
  'recipientName': instance.recipientName,
  'recipientPhone': instance.recipientPhone,
  'location': instance.location,
  'address': instance.address,
  'imageUrl': instance.imageUrl,
};
