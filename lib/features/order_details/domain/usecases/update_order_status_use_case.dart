import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/order_details/data/dtos/requests/update_order_status_request_dto.dart';
import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
import 'package:driver_app/features/order_details/domain/params/update_order_status_params.dart';
import 'package:driver_app/features/order_details/domain/repo/order_details_repo.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class UpdateOrderStatusUseCase {
  UpdateOrderStatusUseCase(this._repository);

  final OrderDetailsRepo _repository;

  Future<BaseResponse<UpdateOrderStatusEntity>> execute(
  UpdateOrderStatusParams params,
  ) => _repository.updateOrderStatus(params);
}
