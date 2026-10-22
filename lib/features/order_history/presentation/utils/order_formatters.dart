import '../constants/order_history_constants.dart';

String shortOrderId(String orderId) {
  const length = OrderHistoryConstants.shortIdLength;
  return orderId.length > length ? orderId.substring(0, length) : orderId;
}

String formatOrderId(String orderId) => '# ${shortOrderId(orderId)}';

String formatQuantity(int quantity) => 'X$quantity';

String formatPrice(double price, String currency) {
  final amount =
      price % 1 == 0 ? price.toInt().toString() : price.toStringAsFixed(2);
  return '$currency $amount';
}
