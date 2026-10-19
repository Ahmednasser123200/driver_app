import 'package:driver_app/config/base/base_response.dart';

import '../entities/order_history_entities.dart';
import '../entities/pagination_entities.dart';

abstract interface class OrderHistoryRepo {

  Future<BaseResponse<PaginatedEntity<OrderHistoryEntity>>> getOrders({
    required int page,
    required int pageSize,
  });

  Future<BaseResponse<OrderHistoryDetailsEntity>> getOrderDetails({
    required String orderId,
  });

  Stream<BaseResponse<OrderHistoryEntity>> watchOrderUpdates();
}
