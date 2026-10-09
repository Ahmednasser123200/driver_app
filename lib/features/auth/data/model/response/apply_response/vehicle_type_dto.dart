import 'package:json_annotation/json_annotation.dart';

import '../../../../domain/entities/apply_entity/vehicle_type_entity.dart';

part 'vehicle_type_dto.g.dart';

@JsonSerializable()
class VehicleTypeDto {
  @JsonKey(name: 'id')
  final int? id; // قد يأتي كـ int أو String من الباك إند
  @JsonKey(name: 'name')
  final String? name;

  const VehicleTypeDto({
    this.id,
    this.name,
  });

  factory VehicleTypeDto.fromJson(Map<String, dynamic> json) =>
      _$VehicleTypeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleTypeDtoToJson(this);
}
extension VehicleTypeDtoMapper on VehicleTypeDto {
  VehicleTypeEntity toEntity() {
    return VehicleTypeEntity(
      id: id?.toString() ?? '',
      name: name ?? '',
    );
  }
}