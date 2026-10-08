import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/home/domain/entities/available_orders.dart';
import 'package:driver_app/features/home/domain/repo/home_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAvailableOrdersUseCase {
  HomeRepo homeRepo;

  GetAvailableOrdersUseCase(this.homeRepo);
  Future<BaseResponse<AvailableOrders>> call({int page = 1}) =>
      homeRepo.getAvailableOrders(page: page);
}
