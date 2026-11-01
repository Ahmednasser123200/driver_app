import 'package:injectable/injectable.dart';
import '../repo/auth_repo.dart';

@injectable
class DeleteRememberedEmailUseCase {
  final AuthRepo _repo;

  DeleteRememberedEmailUseCase(this._repo);

  Future<void> call() => _repo.deleteRememberedEmail();
}
