import 'package:json_annotation/json_annotation.dart';

import 'vehicle_type_dto.dart';

part 'vehicle_types_response_dto.g.dart';

@JsonSerializable()
class VehicleTypesResponseDto {
  final bool? success;
  final String? message;
  final List<VehicleTypeDto>? data;

  const VehicleTypesResponseDto({this.success, this.message, this.data});

  factory VehicleTypesResponseDto.fromJson(Map<String, dynamic> json) =>
      _$VehicleTypesResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleTypesResponseDtoToJson(this);
}
