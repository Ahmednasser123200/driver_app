import 'package:json_annotation/json_annotation.dart';

part 'application_dto.g.dart';

@JsonSerializable()
class ApplicationDto {
  @JsonKey(name: 'applicationId')
  final String? applicationId;
  @JsonKey(name: 'status')
  final String? status;

  const ApplicationDto({
    this.applicationId,
    this.status,
  });

  factory ApplicationDto.fromJson(Map<String, dynamic> json) =>
      _$ApplicationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationDtoToJson(this);
}