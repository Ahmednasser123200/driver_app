import 'package:driver_app/config/base/base_response.dart';
import 'package:injectable/injectable.dart';

import '../repo/auth_repo.dart';

@injectable
class ForgetPasswordUserCase {
  final AuthRepo authRepo;

  ForgetPasswordUserCase(this.authRepo);

  Future<BaseResponse<dynamic>> call({required String email}) {
    return authRepo.forgetPassword(email);
  }
}
