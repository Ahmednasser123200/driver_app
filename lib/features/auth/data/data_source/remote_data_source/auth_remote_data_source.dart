
import '../../model/request/login_request/login_request.dart';
import '../../model/response/login_response/login_response.dart';

abstract interface class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest login);
}