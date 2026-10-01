class OrderItemEntity {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final String imageUrl;

  OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.imageUrl,
  });
}