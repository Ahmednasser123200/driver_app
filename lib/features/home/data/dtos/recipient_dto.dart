import 'package:driver_app/features/home/domain/entities/recipient.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipient_dto.g.dart';

@JsonSerializable()
class RecipientDto {
  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'city')
  final String city;

  @JsonKey(name: 'area')
  final String area;

  RecipientDto({
    required this.name,
    required this.city,
    required this.area,
  });

  factory RecipientDto.fromJson(Map<String, dynamic> json) =>
      _$RecipientDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RecipientDtoToJson(this);

  Recipient toDomain() => Recipient(
    name: name,
    city: city,
    area: area,
  );
}