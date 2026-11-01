import 'package:json_annotation/json_annotation.dart';

import '../../../../domain/entities/apply_entity/country_entity.dart';

part 'country_dto.g.dart';

@JsonSerializable()
class CountryDto {
  @JsonKey(name: 'isoCode')
  final String? isoCode;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'phoneCode')
  final String? phoneCode;
  @JsonKey(name: 'flag')
  final String? flag;

  const CountryDto({this.isoCode, this.name, this.phoneCode, this.flag});

  factory CountryDto.fromJson(Map<String, dynamic> json) =>
      _$CountryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CountryDtoToJson(this);
}

extension CountryDtoMapper on CountryDto {
  CountryEntity toEntity() {
    return CountryEntity(
      isoCode: isoCode ?? '',
      name: name ?? '',
      phoneCode: phoneCode ?? '',
      flag: flag ?? '',
    );
  }
}
