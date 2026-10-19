import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/order_pricing.dart';
import 'package:driver_app/features/order_details/domain/repo/order_details_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetDriverOrderDetailsUseCase {
  GetDriverOrderDetailsUseCase(this._repository);

  final OrderDetailsRepo _repository;

  /// Loads the order and, only when the driver payload comes without prices,
  /// asks the customer order endpoint for them.
  ///
  /// The pricing call is best effort: if it fails (or a driver token is not
  /// allowed on that endpoint) the details are returned untouched so the screen
  /// still works — just without prices instead of with made up ones.
  Future<BaseResponse<DriverOrderDetailsEntity>> execute(String orderId) async {
    final result = await _repository.getOrderDetails(orderId);

    if (result is! Success<DriverOrderDetailsEntity>) return result;
    final data = result.data;

    if (data.totalPrice != null && !_hasMissingItemPrice(data)) {
      return result;
    }

    final pricing = await _repository.getOrderPricing(orderId);
    if (pricing is Success<OrderPricingEntity>) {
      return Success(data.withPricing(pricing.data));
    }

    return result;
  }

  bool _hasMissingItemPrice(DriverOrderDetailsEntity data) =>
      data.items.any((item) => item.unitPrice == null);
}
