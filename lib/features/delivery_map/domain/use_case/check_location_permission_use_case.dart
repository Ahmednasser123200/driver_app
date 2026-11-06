import 'package:driver_app/features/order_details/domain/repo/order_details_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class CheckLocationPermissionUseCase {
  final OrderDetailsRepo _orderDetailsRepo;

  const CheckLocationPermissionUseCase(this._orderDetailsRepo);

  Future<bool> call() =>
      _orderDetailsRepo.checkAndRequestLocationPermission();
}
