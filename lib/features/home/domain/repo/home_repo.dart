import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/home/domain/entities/available_orders.dart';

abstract interface class HomeRepo {
  Future<BaseResponse<AvailableOrders>> getAvailableOrders({int page  =1} );
  Future<BaseResponse<void>> acceptOrder(String orderId);
}