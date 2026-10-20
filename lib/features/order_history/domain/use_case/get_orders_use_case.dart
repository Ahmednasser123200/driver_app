import 'package:driver_app/config/base/base_response.dart';
import 'package:injectable/injectable.dart';

import '../entities/order_history_entities.dart';
import '../entities/pagination_entities.dart';
import '../repo/order_history_repo.dart';

@injectable
class GetOrdersUseCase {
  final OrderHistoryRepo _repo;

  GetOrdersUseCase(this._repo);

  Future<BaseResponse<PaginatedEntity<OrderHistoryEntity>>> execute({
    required int page,
    required int pageSize,
  }) {
    return _repo.getOrders(page: page, pageSize: pageSize);
  }
}