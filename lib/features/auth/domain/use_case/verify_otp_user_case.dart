import 'package:driver_app/config/base/base_response.dart';
import 'package:injectable/injectable.dart';

import '../repo/auth_repo.dart';

@injectable
class VerifyOtpUserCase {
  final AuthRepo authRepo;

  VerifyOtpUserCase(this.authRepo);

  Future<BaseResponse<dynamic>> call({
    required String email,
    required String otp,
  }) {
    return authRepo.verifyOtp(email, otp);
  }
}
