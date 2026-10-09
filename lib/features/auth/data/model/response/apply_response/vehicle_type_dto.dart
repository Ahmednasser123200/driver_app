import 'package:json_annotation/json_annotation.dart';

import '../../../../domain/entities/apply_entity/vehicle_type_entity.dart';

part 'vehicle_type_dto.g.dart';

int? _parseId(dynamic val) {
  if (val == null) return null;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val);
  return null;
}

@JsonSerializable()
class VehicleTypeDto {
  @JsonKey(name: 'id', fromJson: _parseId)
  final int? id;
  @JsonKey(name: 'name')
  final String? name;

  const VehicleTypeDto({this.id, this.name});

  factory VehicleTypeDto.fromJson(Map<String, dynamic> json) =>
      _$VehicleTypeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleTypeDtoToJson(this);
}

extension VehicleTypeDtoMapper on VehicleTypeDto {
  VehicleTypeEntity toEntity() {
    return VehicleTypeEntity(id: id?.toString() ?? '', name: name ?? '');
  }
}
