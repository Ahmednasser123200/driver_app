import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ApiStrings {
  static final String baseUrl = dotenv.env['BASE_URL'] ??'';
  static const String driverOrders = '/order/drivers/me/orders';
  static const String login = '/auth/login';
  static const String orderIdKey = 'orderId';
  static const String productIdKey = 'productId';
  static const String driverOrderDetails =
      '/order/drivers/me/orders/{$orderIdKey}';
  static const String catalogProduct = '/catalog/products/{$productIdKey}';
}
