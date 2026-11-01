import 'package:injectable/injectable.dart';
import '../../../../config/base/base_response.dart';
import '../entities/apply_entity/vehicle_type_entity.dart';
import '../repo/auth_repo.dart';

@injectable
class GetVehicleTypesUseCase {
  final AuthRepo _repo;
  GetVehicleTypesUseCase(this._repo);

  Future<BaseResponse<List<VehicleTypeEntity>>> execute() {
    return _repo.getVehicleTypes();
  }
}
