import 'package:driver_app/features/home/domain/entities/store.dart';
import 'package:json_annotation/json_annotation.dart';

part 'store_dto.g.dart';

@JsonSerializable()
class StoreDto {
  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'address')
  final String address;

  StoreDto({required this.name, required this.address});

  factory StoreDto.fromJson(Map<String, dynamic> json) =>
      _$StoreDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StoreDtoToJson(this);

  Store toDomain() => Store(name: name, address: address);
}
