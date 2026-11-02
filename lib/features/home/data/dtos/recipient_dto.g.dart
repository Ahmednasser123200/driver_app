// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipient_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipientDto _$RecipientDtoFromJson(Map<String, dynamic> json) => RecipientDto(
  name: json['name'] as String,
  city: json['city'] as String,
  area: json['area'] as String,
);

Map<String, dynamic> _$RecipientDtoToJson(RecipientDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'city': instance.city,
      'area': instance.area,
    };
