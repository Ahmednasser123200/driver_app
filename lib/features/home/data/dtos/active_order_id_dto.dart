class ActiveOrderIdDto {
  const ActiveOrderIdDto(this.orderId);

  final String orderId;

  factory ActiveOrderIdDto.fromJson(Map<String, dynamic> json) {
    final responseData = json['data'];
    final order = responseData is Map<String, dynamic> ? responseData : json;
    final orderId = order['orderId'];

    // A driver with no active delivery may get an empty/null payload; that is a
    // valid "none" answer, not an error, so resolve it to an empty id.
    if (orderId is! String) {
      return const ActiveOrderIdDto('');
    }

    return ActiveOrderIdDto(orderId.trim());
  }
}
