import 'package:json_annotation/json_annotation.dart';

part 'report_driver_location_request_dto.g.dart';

@JsonSerializable()
class ReportDriverLocationRequestDto {
  @JsonKey(name: 'lat')
  final double lat;

  @JsonKey(name: 'lng')
  final double lng;

  @JsonKey(name: 'recordedAt')
  final String recordedAt;

  ReportDriverLocationRequestDto({
    required this.lat,
    required this.lng,
    required this.recordedAt,
  });

  factory ReportDriverLocationRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ReportDriverLocationRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportDriverLocationRequestDtoToJson(this);
}