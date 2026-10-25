
extension OrderStatusStringExtension on String {
  String get normalizedOrderStatus =>
      replaceAll(RegExp(r'[\s_-]+'), '').toLowerCase();

  bool get isTerminalOrderStatus {
    final status = normalizedOrderStatus;

    return status == 'arrived' ||
        status == 'delivered' ||
        status == 'awaitingdeliveryconfirmation' ||
        status == 'cancelled';
  }

  bool get isInTransitOrderStatus {
    final status = normalizedOrderStatus;

    return status == 'ontheway' ||
        status == 'outfordelivery' ||
        status == 'pickedup' ||
        status == 'inprogress';
  }
}
