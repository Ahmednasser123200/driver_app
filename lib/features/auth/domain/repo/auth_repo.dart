import 'package:driver_app/config/base/base_response.dart';

abstract class AuthRepo {
  Future<BaseResponse<dynamic>> login(dynamic credentials);
  Future<BaseResponse<dynamic>> register(dynamic registerData);
  Future<BaseResponse<dynamic>> forgetPassword(String email);
  Future<BaseResponse<dynamic>> verifyOtp(String email, String otp);
  Future<BaseResponse<dynamic>> resetPassword(String email, String newPassword);
  Future<void> saveRememberedEmail(String email);
  Future<String?> loadRememberedEmail();
  Future<void> deleteRememberedEmail();
}
