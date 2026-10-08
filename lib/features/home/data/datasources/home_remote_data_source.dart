import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/home/data/dtos/available_orders_response_dto.dart';

abstract interface class HomeRemoteDataSource {
  Future<BaseResponse<AvailableOrdersResponseDto>> getAvailableOrders({int page =1 });
  Future<BaseResponse<void>> acceptOrder(String orderId);
  
}