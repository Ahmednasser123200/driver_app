// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_address_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAddressDto _$UserAddressDtoFromJson(Map<String, dynamic> json) =>
    UserAddressDto(
      recipientName: json['recipientName'] as String?,
      phone: json['recipientPhone'] as String?,
      addressLine: json['address'] as String?,
      location: json['location'] == null
          ? null
          : LocationDto.fromJson(json['location'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserAddressDtoToJson(UserAddressDto instance) =>
    <String, dynamic>{
      'recipientName': instance.recipientName,
      'recipientPhone': instance.phone,
      'address': instance.addressLine,
      'location': instance.location,
    };
