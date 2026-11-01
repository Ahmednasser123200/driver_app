// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountryDto _$CountryDtoFromJson(Map<String, dynamic> json) => CountryDto(
  isoCode: json['isoCode'] as String?,
  name: json['name'] as String?,
  phoneCode: json['phoneCode'] as String?,
  flag: json['flag'] as String?,
);

Map<String, dynamic> _$CountryDtoToJson(CountryDto instance) =>
    <String, dynamic>{
      'isoCode': instance.isoCode,
      'name': instance.name,
      'phoneCode': instance.phoneCode,
      'flag': instance.flag,
    };
