class UpdateOrderStatusEntity {
  final String orderId;
  final String status;
  final String updatedAt;

  UpdateOrderStatusEntity({
    required this.orderId,
    required this.status,
    required this.updatedAt,
  });
}