import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ApiStrings {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  // =========================
  // Authentication
  // =========================

  static const String login = '/auth/login';

  static const String register = '/auth/register';

  static const String adminLogin = '/auth/admin-login';

  static const String refreshToken = '/auth/refresh';

  static const String changePassword = '/auth/change-password';

  static const String forgotPassword = '/auth/forgot-password';

  static const String verifyOtp = '/auth/verify-otp';

  static const String resetPassword = '/auth/reset-password';

  static const String logout = '/auth/logout';

  // =========================
  // User Profile
  // =========================

  static const String getProfile = '/api/users/GetProfile';

  static const String updateProfile = '/api/users/UpdateProfile';

  static const String updateFcmToken = '/api/v1/devices/fcm-token';

  static const String updateNotifications = '/api/v1/devices/notifications';

  // =========================
  // Driver Applications
  // =========================

  static const String submitDriverApplication = '/api/drivers/applications';

  static const String getDriverApplications = '/api/admin/drivers/applications';

  static String getDriverApplicationById(String id) =>
      '/api/admin/drivers/applications/$id';

  static String approveDriverApplication(String id) =>
      '/api/admin/drivers/applications/$id/approve';

  static String rejectDriverApplication(String id) =>
      '/api/admin/drivers/applications/$id/reject';

  static String getDriverProfile(String driverId) =>
      '/api/drivers/$driverId/profile';

  static const String getVehicleTypes = '/api/v1/vehicle-types';

  static const String getCountries = '/api/v1/countries';

  static const String getDriverVehicle = '/api/v1/drivers/me/vehicle';

  static const String updateDriverVehicle = '/api/v1/drivers/me/vehicle';

  // =========================
  // Catalog & Home
  // =========================

  static const String homeSections = '/catalog/home/sections';

  static const String occasions = '/catalog/occasions';

  static const String products = '/catalog/products';

  static String productDetails(String productId) =>
      '/catalog/products/$productId';

  static const String categories = '/catalog/categories';

  // =========================
  // Cart
  // =========================

  static const String getCart = '/cart/cart';

  static const String addCartItem = '/api/v1/cart/items';

  static const String addCartItemLegacy = '/cart/cart/items';

  static String updateCartItem(String productId) =>
      '/cart/api/cart/items/$productId';

  static String removeCartItem(String id) => '/cart/cart/items/$id';

  static const String clearCart = '/cart/cart';

  // =========================
  // Checkout
  // =========================

  static const String checkoutDetails = '/checkout/details';

  static const String estimateDelivery = '/checkout/estimate-delivery';

  // =========================
  // Orders - Customer
  // =========================

  static const String placeOrder = '/orders/place';

  static const String customerOrders = '/orders';

  static String orderDetails(String orderId) => '/orders/$orderId';

  static String orderTracking(String orderId) => '/orders/$orderId/tracking';

  static String confirmOrderDelivery(String orderId) =>
      '/orders/$orderId/confirm-delivery';

  static String cancelOrder(String orderId) => '/orders/$orderId/cancel';

  // =========================
  // Payments
  // =========================

  static const String createCheckoutSession = '/payments/checkout-session';

  static const String createCodPayment = '/payments/cod';

  static String paymentStatus(String orderId) =>
      '/payments/orders/$orderId/status';

  static String retryPayment(String orderId) =>
      '/payments/orders/$orderId/retry';

  static const String paymentWebhook = '/payments/webhook';

  // =========================
  // Driver Orders
  // =========================

  static const String orderIdPath = 'orderId';

  static const String availableOrders = '/order/drivers/available-orders';

  static String acceptOrder(String orderId) =>
      '/order/drivers/me/orders/$orderId/accept';

  static const String activeOrder = '/order/drivers/me/active-order';

  static const String driverOrderHistory = '/order/drivers/me/orders';

  static const String driverOrderDetailsRoute =
      '/order/drivers/me/orders/{$orderIdPath}';

  static String driverOrderDetails(String orderId) =>
      '/order/drivers/me/orders/$orderId';

  static const String updateOrderStatusRoute =
      '/order/orders/{$orderIdPath}/status';

  static String updateOrderStatus(String orderId) =>
      '/order/orders/$orderId/status';

  static const String reportDriverLocation = '/order/drivers/me/location';

  // =========================
  // Address
  // =========================

  static const String areas = '/address/api/areas';

  static const String nearestStore = '/address/api/stores/nearest-store';

  static const String userAddresses = '/address/users/me/addresses';

  static String addressById(String addressId) =>
      '/address/users/me/addresses/$addressId';

  static String setDefaultAddress(String addressId) =>
      '/address/users/me/addresses/$addressId/default';

  // =========================
  // Admin - Stores
  // =========================

  static const String adminStores = '/address/admin/stores';

  static String adminStoreById(String storeId) =>
      '/address/admin/stores/$storeId';

  static String adminStoreCoverageArea(String storeId) =>
      '/address/admin/stores/$storeId/coverage-area';
}
