// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_address_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAddressDto _$UserAddressDtoFromJson(Map<String, dynamic> json) =>
    UserAddressDto(
      recipientName: json['recipientName'] as String,
      phone: json['phone'] as String,
      addressLine: json['addressLine'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$UserAddressDtoToJson(UserAddressDto instance) =>
    <String, dynamic>{
      'recipientName': instance.recipientName,
      'phone': instance.phone,
      'addressLine': instance.addressLine,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
