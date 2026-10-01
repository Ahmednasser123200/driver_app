import 'package:driver_app/features/order_details/domain/entities/timeline.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timeline_dto.g.dart';

@JsonSerializable()
class TimelineDto {
  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'timestamp')
  final String timestamp;

  TimelineDto({
    required this.status,
    required this.timestamp,
  });

  factory TimelineDto.fromJson(Map<String, dynamic> json) =>
      _$TimelineDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineDtoToJson(this);

  TimelineEntity toDomain() => TimelineEntity(
    status: status,
    timestamp: timestamp,
  );
}