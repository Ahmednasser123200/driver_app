import 'package:driver_app/config/base/base_response.dart';
import 'package:injectable/injectable.dart';

import '../entities/forget_entity/forget_password_entity.dart';
import '../repo/auth_repo.dart';

@injectable
class ForgetPasswordUserCase {
  final AuthRepo authRepo;

  ForgetPasswordUserCase(this.authRepo);

  Future<BaseResponse<ForgetPasswordEntity>> call({required String email}) {
    return authRepo.forgetPassword(email);
  }
}
