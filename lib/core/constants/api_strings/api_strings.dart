import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ApiStrings {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  static const String availableOrders = '/order/drivers/available-orders';
  static const String acceptOrder = "/order/drivers/me/orders/{orderId}/accept";
}
