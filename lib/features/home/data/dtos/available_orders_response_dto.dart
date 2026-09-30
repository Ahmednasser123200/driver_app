import 'package:driver_app/features/home/data/dtos/available_order_dto.dart';
import 'package:driver_app/features/home/data/dtos/pagination_dto.dart';
import 'package:driver_app/features/home/domain/entities/available_orders.dart';
import 'package:json_annotation/json_annotation.dart';

part 'available_orders_response_dto.g.dart';

@JsonSerializable()
class AvailableOrdersResponseDto {
  @JsonKey(name: 'items')
  final List<AvailableOrderDto> items;

  @JsonKey(name: 'pagination')
  final PaginationDto pagination;

  AvailableOrdersResponseDto({
    required this.items,
    required this.pagination,
  });

  factory AvailableOrdersResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AvailableOrdersResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AvailableOrdersResponseDtoToJson(this);

  AvailableOrders toDomain() => AvailableOrders(
    items: items.map((item) => item.toDomain()).toList(),
    pagination: pagination.toDomain(),
  );
}