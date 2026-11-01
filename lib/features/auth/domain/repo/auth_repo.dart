import 'package:driver_app/config/base/base_response.dart';

import '../entities/apply_entity/applications_entity.dart';
import '../entities/apply_entity/country_entity.dart';
import '../entities/apply_entity/vehicle_type_entity.dart';
import '../entities/forget_entity/forget_password_entity.dart';
import '../entities/forget_entity/reset_passsword_entity.dart';
import '../entities/forget_entity/verify_oto_entity.dart';
import '../entities/login_entity/login_credentials.dart';
import '../entities/login_entity/login_entity.dart';

abstract interface class AuthRepo {
  Future<BaseResponse<LoginEntity>> login(
    LoginCredentials credentials, {
    bool rememberMe = false,
  });

  Future<BaseResponse<ForgetPasswordEntity>> forgetPassword(String email);
  Future<BaseResponse<VerifyOtpEntity>> verifyOtp(String email, String otp);
  Future<BaseResponse<ResetPasswordEntity>> resetPassword({
    required String email,
    required String otp,
    required String password,
  });
  Future<void> saveRememberedEmail(String email);
  Future<String?> loadRememberedEmail();
  Future<void> deleteRememberedEmail();

  Future<BaseResponse<void>> addApplication(ApplicationEntity application);
  Future<BaseResponse<List<CountryEntity>>> getCountries();
  Future<BaseResponse<List<VehicleTypeEntity>>> getVehicleTypes();
}
