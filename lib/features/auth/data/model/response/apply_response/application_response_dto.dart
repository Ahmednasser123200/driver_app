import 'package:json_annotation/json_annotation.dart';

import 'application_dto.dart';

part 'application_response_dto.g.dart';

@JsonSerializable()
class ApplicationResponseDto {
  final bool? success;
  final String? message;
  final ApplicationDto? data;
  final ErrorDto? error;

  const ApplicationResponseDto({
    this.success,
    this.message,
    this.data,
    this.error,
  });

  factory ApplicationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ApplicationResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationResponseDtoToJson(this);
}

@JsonSerializable()
class ErrorDto {
  final String? code;
  final String? field;

  const ErrorDto({this.code, this.field});

  factory ErrorDto.fromJson(Map<String, dynamic> json) =>
      _$ErrorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorDtoToJson(this);
}