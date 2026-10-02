import 'package:driver_app/config/base/base_response.dart';
import 'package:injectable/injectable.dart';

import '../entities/apply_entity/applications_entity.dart';
import '../repo/auth_repo.dart';

@injectable
class AddApplicationUseCase {
  final AuthRepo _repo;
  AddApplicationUseCase(this._repo);

  Future<BaseResponse<void>> execute(ApplicationEntity application) {
    return _repo.addApplication(application);
  }
}