import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_credentials.dart';
import 'package:driver_app/features/auth/domain/entities/login_entity/login_entity.dart';
import 'package:driver_app/features/auth/domain/repo/auth_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginUseCase {
  final AuthRepo _repo;

  LoginUseCase(this._repo);

  Future<BaseResponse<LoginEntity>> call(
      LoginCredentials credentials, {
        bool rememberMe = false,
      }) {
    return _repo.login(credentials, rememberMe: rememberMe);
  }
}