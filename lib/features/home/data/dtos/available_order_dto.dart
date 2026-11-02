import 'package:driver_app/features/home/data/dtos/recipient_dto.dart';
import 'package:driver_app/features/home/data/dtos/store_dto.dart';
import 'package:driver_app/features/home/domain/entities/available_order.dart';
import 'package:json_annotation/json_annotation.dart';

part 'available_order_dto.g.dart';

@JsonSerializable()
class AvailableOrderDto {
  @JsonKey(name: 'orderId')
  final String orderId;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'store')
  final StoreDto store;

  @JsonKey(name: 'recipient')
  final RecipientDto recipient;

  @JsonKey(name: 'itemCount')
  final int itemCount;

  @JsonKey(name: 'total')
  final double total;

  @JsonKey(name: 'estimatedDeliveryAt')
  final DateTime? estimatedDeliveryAt;

  @JsonKey(name: 'deliveredAt')
  final DateTime? deliveredAt;

  @JsonKey(name: 'assignedAt')
  final DateTime? assignedAt;

  AvailableOrderDto({
    required this.orderId,
    required this.status,
    required this.store,
    required this.recipient,
    required this.itemCount,
    required this.total,
    this.estimatedDeliveryAt,
    this.deliveredAt,
    this.assignedAt,
  });

  factory AvailableOrderDto.fromJson(Map<String, dynamic> json) =>
      _$AvailableOrderDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AvailableOrderDtoToJson(this);

  AvailableOrder toDomain() => AvailableOrder(
    orderId: orderId,
    status: status,
    store: store.toDomain(),
    recipient: recipient.toDomain(),
    itemCount: itemCount,
    total: total,
    estimatedDeliveryAt: estimatedDeliveryAt,
    deliveredAt: deliveredAt,
    assignedAt: assignedAt,
  );
}