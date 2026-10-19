import 'package:driver_app/config/base/base_response.dart';
import 'package:injectable/injectable.dart';

import '../entities/order_history_entities.dart';
import '../repo/order_history_repo.dart';

@injectable
class WatchOrderUpdatesUseCase {
  final OrderHistoryRepo _repo;

  WatchOrderUpdatesUseCase(this._repo);

  Stream<BaseResponse<OrderHistoryEntity>> execute() {
    return _repo.watchOrderUpdates();
  }
}