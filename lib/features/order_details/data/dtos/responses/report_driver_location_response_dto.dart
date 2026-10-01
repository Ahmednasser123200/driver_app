import 'package:driver_app/features/order_details/domain/entities/report_driver_location.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_driver_location_response_dto.g.dart';

@JsonSerializable()
class ReportDriverLocationResponseDto {
  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'recordedAt')
  final String recordedAt;

  ReportDriverLocationResponseDto({
    required this.success,
    required this.recordedAt,
  });

  factory ReportDriverLocationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ReportDriverLocationResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportDriverLocationResponseDtoToJson(this);

  ReportDriverLocationEntity toDomain() => ReportDriverLocationEntity(
    success: success,
    recordedAt: recordedAt,
  );
}