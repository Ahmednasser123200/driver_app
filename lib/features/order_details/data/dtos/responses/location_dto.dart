import 'package:json_annotation/json_annotation.dart';

part 'location_dto.g.dart';

@JsonSerializable()
class LocationDto {
  @JsonKey(name: 'lat')
  final double? lat;

  @JsonKey(name: 'lng')
  final double? lng;

  LocationDto({this.lat, this.lng});

  factory LocationDto.fromJson(Map<String, dynamic> json) =>
      _$LocationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LocationDtoToJson(this);
}
