// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pickup_address_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PickupAddressDto _$PickupAddressDtoFromJson(Map<String, dynamic> json) =>
    PickupAddressDto(
      storeName: json['storeName'] as String?,
      addressLine: json['address'] as String?,
      location: json['location'] == null
          ? null
          : LocationDto.fromJson(json['location'] as Map<String, dynamic>),
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$PickupAddressDtoToJson(PickupAddressDto instance) =>
    <String, dynamic>{
      'storeName': instance.storeName,
      'address': instance.addressLine,
      'location': instance.location,
      'phone': instance.phone,
    };
