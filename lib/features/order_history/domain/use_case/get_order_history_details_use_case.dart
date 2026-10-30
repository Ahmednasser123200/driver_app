
import 'package:injectable/injectable.dart';

import '../../../../config/base/base_response.dart';
import '../../../../config/errors/app_failure.dart';
import '../entities/order_history_entities.dart';
import '../repo/order_history_repo.dart';

@injectable
class GetOrderHistoryDetailsUseCase {
  final OrderHistoryRepo _repo;

  GetOrderHistoryDetailsUseCase(this._repo);

  Future<BaseResponse<OrderHistoryDetailsEntity>> execute({
    required String orderId,
  }) async {
    if (orderId.trim().isEmpty) return Error(const NotFoundFailure());
    return _repo.getOrderDetails(orderId: orderId);
  }
}