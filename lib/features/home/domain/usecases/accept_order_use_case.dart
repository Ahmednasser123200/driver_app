import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/home/domain/repo/home_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class AcceptOrderUseCase {
 final HomeRepo homeRepo;

  AcceptOrderUseCase(this.homeRepo);

  Future<BaseResponse<void>> call(String orderId) =>
      homeRepo.acceptOrder(orderId);
}
