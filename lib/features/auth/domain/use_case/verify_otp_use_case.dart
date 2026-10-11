import 'package:driver_app/config/base/base_response.dart';
import 'package:injectable/injectable.dart';

import '../entities/forget_entity/verify_oto_entity.dart';
import '../repo/auth_repo.dart';

@injectable
class VerifyOtpUseCase {
  final AuthRepo authRepo;

  VerifyOtpUseCase(this.authRepo);

  Future<BaseResponse<VerifyOtpEntity>> call({
    required String email,
    required String otp,
  }) {
    return authRepo.verifyOtp(email, otp);
  }
}
