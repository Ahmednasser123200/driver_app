import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/repo/order_details_repo.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetDriverOrderDetailsUseCase {
  GetDriverOrderDetailsUseCase(this._repository);

  final OrderDetailsRepo _repository;

  Future<BaseResponse<DriverOrderDetailsEntity>> execute(String orderId) =>
      _repository.getOrderDetails(orderId);
}
