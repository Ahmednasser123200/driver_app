// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pickup_address_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PickupAddressDto _$PickupAddressDtoFromJson(Map<String, dynamic> json) =>
    PickupAddressDto(
      storeName: json['storeName'] as String,
      addressLine: json['addressLine'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$PickupAddressDtoToJson(PickupAddressDto instance) =>
    <String, dynamic>{
      'storeName': instance.storeName,
      'addressLine': instance.addressLine,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
