import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_order_status_response_dto.g.dart';

@JsonSerializable()
class UpdateOrderStatusResponseDto {
  @JsonKey(name: 'orderId')
  final String orderId;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'updatedAt')
  final String updatedAt;

  UpdateOrderStatusResponseDto({
    required this.orderId,
    required this.status,
    required this.updatedAt,
  });

  factory UpdateOrderStatusResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateOrderStatusResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateOrderStatusResponseDtoToJson(this);

  UpdateOrderStatusEntity toDomain() => UpdateOrderStatusEntity(
    orderId: orderId,
    status: status,
    updatedAt: updatedAt,
  );
}