import 'package:driver_app/features/order_details/domain/entities/order_item.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_item_dto.g.dart';

@JsonSerializable()
class OrderItemDto {
  @JsonKey(name: 'productId')
  final String productId;

  @JsonKey(name: 'productName')
  final String productName;

  @JsonKey(name: 'quantity')
  final int quantity;

  @JsonKey(name: 'unitPrice')
  final double unitPrice;

  @JsonKey(name: 'imageUrl')
  final String imageUrl;

  OrderItemDto({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.imageUrl,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) =>
      _$OrderItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemDtoToJson(this);

  OrderItemEntity toDomain() => OrderItemEntity(
    productId: productId,
    productName: productName,
    quantity: quantity,
    unitPrice: unitPrice,
    imageUrl: imageUrl,
  );
}