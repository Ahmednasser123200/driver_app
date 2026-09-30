// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_orders_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailableOrdersResponseDto _$AvailableOrdersResponseDtoFromJson(
  Map<String, dynamic> json,
) => AvailableOrdersResponseDto(
  items: (json['items'] as List<dynamic>)
      .map((e) => AvailableOrderDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: PaginationDto.fromJson(
    json['pagination'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$AvailableOrdersResponseDtoToJson(
  AvailableOrdersResponseDto instance,
) => <String, dynamic>{
  'items': instance.items,
  'pagination': instance.pagination,
};
