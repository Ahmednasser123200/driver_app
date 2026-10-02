
import 'package:injectable/injectable.dart';

import '../repo/auth_repo.dart';

@injectable
class DeleteRememberedEmailUseCase {
  final AuthRepo repo;

  DeleteRememberedEmailUseCase(this.repo);

  Future<void> call() => repo.deleteRememberedEmail();
}
