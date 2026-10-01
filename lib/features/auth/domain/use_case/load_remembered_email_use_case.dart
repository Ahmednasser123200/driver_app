
import 'package:injectable/injectable.dart';

import '../repo/auth_repo.dart';

@injectable
class LoadRememberedEmailUseCase {
  final AuthRepo repo;

  LoadRememberedEmailUseCase(this.repo);

  Future<String?> call() => repo.getRememberedEmail();
}
