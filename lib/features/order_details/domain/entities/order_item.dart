
import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String productId;
  final String productName;
  final int quantity;

  /// Unit price, or null when the backend did not send one. It is never
  /// fabricated so the UI can tell "no price" apart from a real `0.00`.
  final double? unitPrice;
  final String imageUrl;

  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.imageUrl,
  });

  /// `unitPrice * quantity` when the unit price is known, otherwise null.
  double? get lineTotal => unitPrice == null ? null : unitPrice! * quantity;

  OrderItemEntity copyWith({double? unitPrice, String? productName}) =>
      OrderItemEntity(
        productId: productId,
        productName: productName ?? this.productName,
        quantity: quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        imageUrl: imageUrl,
      );

  @override
  List<Object?> get props => [
        productId,
        productName,
        quantity,
        unitPrice,
        imageUrl,
      ];
}
