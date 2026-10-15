import 'package:injectable/injectable.dart';
import '../repo/auth_repo.dart';

@injectable
class SaveRememberedEmailUseCase {
  final AuthRepo _repo;

  SaveRememberedEmailUseCase(this._repo);

  Future<void> call(String email) => _repo.saveRememberedEmail(email);
}
