import 'package:driver_app/features/home/data/dtos/available_orders_data_dto.dart';
import 'package:driver_app/features/home/domain/entities/available_orders.dart';
import 'package:json_annotation/json_annotation.dart';

part 'available_orders_response_dto.g.dart';

@JsonSerializable()
class AvailableOrdersResponseDto {
  @JsonKey(name: 'success')
  final bool? success;

  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'data')
  final AvailableOrdersDataDto data;

  AvailableOrdersResponseDto({this.success, this.message, required this.data});

  factory AvailableOrdersResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AvailableOrdersResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AvailableOrdersResponseDtoToJson(this);

  AvailableOrders toDomain() => data.toDomain();
}
