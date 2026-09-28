import 'package:driver_app/config/base/base_response.dart';

import '../entities/apply_entity/applications_entity.dart';

abstract interface class AuthRepo {
 Future<BaseResponse<void>> addApplication(ApplicationEntity application);
}