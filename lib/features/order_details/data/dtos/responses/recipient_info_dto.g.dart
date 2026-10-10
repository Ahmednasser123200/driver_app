// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipient_info_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipientInfoDto _$RecipientInfoDtoFromJson(Map<String, dynamic> json) =>
    RecipientInfoDto(
      isGift: json['isGift'] as bool,
      recipientName: json['recipientName'] as String,
      recipientPhone: json['recipientPhone'] as String,
    );

Map<String, dynamic> _$RecipientInfoDtoToJson(RecipientInfoDto instance) =>
    <String, dynamic>{
      'isGift': instance.isGift,
      'recipientName': instance.recipientName,
      'recipientPhone': instance.recipientPhone,
    };
