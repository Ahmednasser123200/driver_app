import 'package:driver_app/config/base/base_response.dart';

import '../entities/apply_entity/applications_entity.dart';
import '../entities/apply_entity/country_entity.dart';
import '../entities/apply_entity/vehicle_type_entity.dart';

abstract interface class AuthRepo {
  Future<BaseResponse<void>> addApplication(ApplicationEntity application);
  Future<BaseResponse<List<CountryEntity>>> getCountries();
  Future<BaseResponse<List<VehicleTypeEntity>>> getVehicleTypes();
}
