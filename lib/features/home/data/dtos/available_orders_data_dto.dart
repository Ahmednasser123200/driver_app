import 'package:driver_app/features/home/data/dtos/available_order_dto.dart';
import 'package:driver_app/features/home/data/dtos/pagination_dto.dart';
import 'package:driver_app/features/home/domain/entities/available_orders.dart';
import 'package:json_annotation/json_annotation.dart';

part 'available_orders_data_dto.g.dart';

@JsonSerializable()
class AvailableOrdersDataDto {
  @JsonKey(name: 'items')
  final List<AvailableOrderDto> items;

  @JsonKey(name: 'pagination')
  final PaginationDto pagination;

  AvailableOrdersDataDto({required this.items, required this.pagination});

  factory AvailableOrdersDataDto.fromJson(Map<String, dynamic> json) =>
      _$AvailableOrdersDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AvailableOrdersDataDtoToJson(this);

  AvailableOrders toDomain() {
    return AvailableOrders(
      items: items.map((e) => e.toDomain()).toList(),
      pagination: pagination.toDomain(),
    );
  }
}