import 'package:driver_app/config/base/base_response.dart';

import '../entities/forget_entity/forget_password_entity.dart';
import '../entities/forget_entity/reset_passsword_entity.dart';
import '../entities/forget_entity/verify_oto_entity.dart';

abstract class AuthRepo {
  Future<BaseResponse<dynamic>> login(dynamic credentials);
  Future<BaseResponse<dynamic>> register(dynamic registerData);
  Future<BaseResponse<ForgetPasswordEntity>> forgetPassword(String email);
  Future<BaseResponse<VerifyOtpEntity>> verifyOtp(String email, String otp);
  Future<BaseResponse<ResetPassswordEntity>> resetPassword({
    required String email,
    required String otp,
    required String password,
  });
  Future<void> saveRememberedEmail(String email);
  Future<String?> loadRememberedEmail();
  Future<void> deleteRememberedEmail();
}
