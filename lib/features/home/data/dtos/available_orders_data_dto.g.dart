// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_orders_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailableOrdersDataDto _$AvailableOrdersDataDtoFromJson(
  Map<String, dynamic> json,
) => AvailableOrdersDataDto(
  items: (json['items'] as List<dynamic>)
      .map((e) => AvailableOrderDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: PaginationDto.fromJson(
    json['pagination'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$AvailableOrdersDataDtoToJson(
  AvailableOrdersDataDto instance,
) => <String, dynamic>{
  'items': instance.items,
  'pagination': instance.pagination,
};
