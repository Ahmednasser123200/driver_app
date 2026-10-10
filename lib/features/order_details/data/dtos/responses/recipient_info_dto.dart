import 'package:driver_app/features/order_details/domain/entities/recipient_info.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipient_info_dto.g.dart';

@JsonSerializable()
class RecipientInfoDto {
  @JsonKey(name: 'isGift')
  final bool isGift;

  @JsonKey(name: 'recipientName')
  final String recipientName;

  @JsonKey(name: 'recipientPhone')
  final String recipientPhone;

  RecipientInfoDto({
    required this.isGift,
    required this.recipientName,
    required this.recipientPhone,
  });

  factory RecipientInfoDto.fromJson(Map<String, dynamic> json) =>
      _$RecipientInfoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RecipientInfoDtoToJson(this);

  RecipientInfoEntity toDomain() => RecipientInfoEntity(
    isGift: isGift,
    recipientName: recipientName,
    recipientPhone: recipientPhone,
  );
}