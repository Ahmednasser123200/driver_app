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

  /// `unitPrice * quantity` when both are known, otherwise null. A zero
  /// quantity is treated as "not received" so the UI never shows a fabricated
  /// `0.00` subtotal.
  double? get lineTotal =>
      unitPrice == null || quantity <= 0 ? null : unitPrice! * quantity;

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
