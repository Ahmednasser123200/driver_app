import '../../../../config/base/base_response.dart';
import '../model/order_details_response_dto.dart';
import '../model/order_history_list_response_dto.dart';
import '../model/order_history_request_dto.dart';
import '../model/product_response_dto.dart';

abstract interface class OrderHistoryRemoteDataSource {
  Future<BaseResponse<OrderHistoryResponseDto>> getOrders(
      OrderHistoryRequestDto request,
      );

  Future<BaseResponse<OrderDetailsResponseDto>> getOrderDetails(
      String orderId,
      );

  Future<BaseResponse<ProductResponseDto>> getProduct(String productId);
}