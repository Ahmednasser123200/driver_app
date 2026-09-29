import 'package:driver_app/config/base/base_response.dart';

import '../entities/login_entity/login_credentials.dart';
import '../entities/login_entity/login_entity.dart';

abstract class AuthRepo {
  Future<BaseResponse<LoginEntity>> login(LoginCredentials credentials, {bool rememberMe = false});
}
