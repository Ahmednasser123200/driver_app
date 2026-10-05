class UpdateOrderStatusParams {
  final String orderId;
  final String newStatus;

  const UpdateOrderStatusParams({
    required this.orderId,
    required this.newStatus,
  });
}