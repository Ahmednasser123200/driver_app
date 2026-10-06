import 'package:json_annotation/json_annotation.dart';

import 'application_dto.dart';

part 'application_response_dto.g.dart';

@JsonSerializable()
class ApplicationResponseDto {
  final bool? success;
  final String? message;
  final ApplicationDto? data;

  const ApplicationResponseDto({
    this.success,
    this.message,
    this.data,
  });

  factory ApplicationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ApplicationResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationResponseDtoToJson(this);
}