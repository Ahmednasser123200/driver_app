import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/order_details/domain/entities/user_location_entity.dart';
import 'package:driver_app/features/order_details/domain/repo/order_details_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetCurrentDriverLocationUseCase {
  final OrderDetailsRepo _orderDetailsRepo;

  const GetCurrentDriverLocationUseCase(this._orderDetailsRepo);

  Future<BaseResponse<UserLocationEntity?>> call() =>
      _orderDetailsRepo.getCurrentDriverLocation();
}
