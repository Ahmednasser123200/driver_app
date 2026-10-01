
import 'package:injectable/injectable.dart';

import '../repo/auth_repo.dart';

@injectable
class SaveRememberedEmailUseCase {
  final AuthRepo repo;

  SaveRememberedEmailUseCase(this.repo);

  Future<void> call(String email) => repo.saveRememberedEmail(email);
}
