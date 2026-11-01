// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_history_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderHistoryRequestDto _$OrderHistoryRequestDtoFromJson(
  Map<String, dynamic> json,
) => OrderHistoryRequestDto(
  page: (json['page'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
);

Map<String, dynamic> _$OrderHistoryRequestDtoToJson(
  OrderHistoryRequestDto instance,
) => <String, dynamic>{'page': instance.page, 'pageSize': instance.pageSize};
