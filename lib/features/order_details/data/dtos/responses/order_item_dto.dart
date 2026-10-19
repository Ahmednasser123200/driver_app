import 'package:driver_app/features/order_details/domain/entities/order_item.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_item_dto.g.dart';

/// The backend only sends `productId`, `productName` and `quantity` today, so
/// every other field is nullable and defaulted in [toDomain].
@JsonSerializable()
class OrderItemDto {
  @JsonKey(name: 'productId')
  final String? productId;

  @JsonKey(name: 'productName')
  final String? productName;

  @JsonKey(name: 'quantity')
  final int? quantity;

  @JsonKey(name: 'unitPrice')
  final double? unitPrice;

  @JsonKey(name: 'imageUrl')
  final String? imageUrl;

  OrderItemDto({
    this.productId,
    this.productName,
    this.quantity,
    this.unitPrice,
    this.imageUrl,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) =>
      _$OrderItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemDtoToJson(this);

  OrderItemEntity toDomain() => OrderItemEntity(
    productId: productId ?? '',
    productName: productName ?? '',
    quantity: quantity ?? 0,
    // Kept null when absent so the UI never shows a fabricated 0.00.
    unitPrice: unitPrice,
    imageUrl: imageUrl ?? '',
  );
}
