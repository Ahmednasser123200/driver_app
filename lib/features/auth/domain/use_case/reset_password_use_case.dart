import 'package:driver_app/config/base/base_response.dart';
import 'package:injectable/injectable.dart';

import '../entities/forget_entity/reset_passsword_entity.dart';
import '../repo/auth_repo.dart';

@injectable
class ResetPasswordUserCase {
  final AuthRepo authRepo;

  ResetPasswordUserCase(this.authRepo);

  Future<BaseResponse<ResetPasswordEntity>> call({
    required String email,
    required String otp,
    required String password,
  }) {
    return authRepo.resetPassword(email: email, otp: otp, password: password);
  }
}
