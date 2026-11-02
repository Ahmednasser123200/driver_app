import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ApiStrings {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String adminLogin = '/auth/admin-login';
  static const String refreshToken = '/auth/refresh';
  static const String changePassword = '/auth/change-password';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String logout = '/auth/logout';

  static const String getProfile = '/api/users/GetProfile';
  static const String updateProfile = '/api/users/UpdateProfile';
  static const String updateFcmToken = '/api/v1/devices/fcm-token';
  static const String updateNotifications = '/api/v1/devices/notifications';

  static const String driverApplications = '/api/drivers/applications';
  static const String submitDriverApplication = driverApplications;
  static const String getDriverApplications = '/api/admin/drivers/applications';
  static String getDriverApplicationById(String id) =>
      '/api/admin/drivers/applications/$id';
  static String approveDriverApplication(String id) =>
      '/api/admin/drivers/applications/$id/approve';
  static String rejectDriverApplication(String id) =>
      '/api/admin/drivers/applications/$id/reject';
  static String getDriverProfile(String driverId) =>
      '/api/drivers/$driverId/profile';
  static const String vehicleTypes = '/api/v1/vehicle-types';
  static const String getVehicleTypes = vehicleTypes;
  static const String countries = '/api/v1/countries';
  static const String getCountries = countries;
  static const String vehicleLicenceFile = 'VehicleLicenceFile';
  static const String idImage = 'IdImage';
  static const String getDriverVehicle = '/api/v1/drivers/me/vehicle';
  static const String updateDriverVehicle = '/api/v1/drivers/me/vehicle';

  static const String homeSections = '/catalog/home/sections';
  static const String occasions = '/catalog/occasions';
  static const String products = '/catalog/products';
  static String productDetails(String productId) =>
      '/catalog/products/$productId';
  static const String categories = '/catalog/categories';
  static const String productIdKey = 'productId';
  static const String catalogProduct = '/catalog/products/{$productIdKey}';

  static const String getCart = '/cart/cart';
  static const String addCartItem = '/api/v1/cart/items';
  static const String addCartItemLegacy = '/cart/cart/items';
  static String updateCartItem(String productId) =>
      '/cart/api/cart/items/$productId';
  static String removeCartItem(String id) => '/cart/cart/items/$id';
  static const String clearCart = '/cart/cart';

  static const String checkoutDetails = '/checkout/details';
  static const String estimateDelivery = '/checkout/estimate-delivery';
  static const String estimationTime = estimateDelivery;

  static const String placeOrder = '/orders/place';
  static const String customerOrders = '/orders';
  static String orderDetails(String orderId) => '/orders/$orderId';
  static String orderTracking(String orderId) => '/orders/$orderId/tracking';
  static String confirmOrderDelivery(String orderId) =>
      '/orders/$orderId/confirm-delivery';
  static String cancelOrder(String orderId) => '/orders/$orderId/cancel';

  static const String createCheckoutSession = '/payments/checkout-session';
  static const String createCodPayment = '/payments/cod';
  static String paymentStatus(String orderId) =>
      '/payments/orders/$orderId/status';
  static String retryPayment(String orderId) =>
      '/payments/orders/$orderId/retry';
  static const String paymentWebhook = '/payments/webhook';

  static const String orderIdKey = 'orderId';
  static const String orderIdPath = orderIdKey;
  static const String driverOrders = '/order/drivers/me/orders';
  static const String driverOrderHistory = driverOrders;
  static const String availableOrders = '/order/drivers/available-orders';
  static String acceptOrder(String orderId) =>
      '/order/drivers/me/orders/$orderId/accept';
  static const String activeOrder = '/order/drivers/me/active-order';
  static const String driverOrderDetails =
      '/order/drivers/me/orders/{$orderIdKey}';
  static const String driverOrderDetailsRoute = driverOrderDetails;
  static String driverOrderDetailsById(String orderId) =>
      '/order/drivers/me/orders/$orderId';
  static const String ordersEndpoint = '/api/v1/orders';
  static const String pageQuery = 'page';
  static const String limitQuery = 'limit';
  static const String updateOrderStatusRoute =
      '/order/orders/{$orderIdPath}/status';
  static String updateOrderStatus(String orderId) =>
      '/order/orders/$orderId/status';
  static const String reportDriverLocation = '/order/drivers/me/location';

  static const String areas = '/address/api/areas';
  static const String nearestStore = '/address/api/stores/nearest-store';
  static const String userAddresses = '/address/users/me/addresses';
  static String addressById(String addressId) =>
      '/address/users/me/addresses/$addressId';
  static String setDefaultAddress(String addressId) =>
      '/address/users/me/addresses/$addressId/default';
  static const String adminStores = '/address/admin/stores';
  static String adminStoreById(String storeId) =>
      '/address/admin/stores/$storeId';
  static String adminStoreCoverageArea(String storeId) =>
      '/address/admin/stores/$storeId/coverage-area';
}
