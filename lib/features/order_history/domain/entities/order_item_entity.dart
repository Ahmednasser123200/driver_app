import 'package:equatable/equatable.dart';

import 'order_product_entity.dart';

class OrderItemEntity extends Equatable {
  final String productId;
  final int quantity;
  final OrderProductEntity product;

  const OrderItemEntity({
    required this.productId,
    required this.quantity,
    required this.product,
  });

  @override
  List<Object?> get props => [productId, quantity, product];
}
