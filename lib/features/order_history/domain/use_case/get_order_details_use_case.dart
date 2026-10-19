import 'package:driver_app/config/base/base_response.dart';
import 'package:injectable/injectable.dart';

import '../entities/order_history_entities.dart';
import '../repo/order_history_repo.dart';

@injectable
class GetOrderDetailsUseCase {
  final OrderHistoryRepo _repo;

  GetOrderDetailsUseCase(this._repo);

  Future<BaseResponse<OrderHistoryDetailsEntity>> execute({
    required String orderId,
  }) {
    return _repo.getOrderDetails(orderId: orderId);
  }
}