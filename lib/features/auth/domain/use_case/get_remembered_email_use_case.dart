import 'package:injectable/injectable.dart';
import '../repo/auth_repo.dart';

@injectable
class GetRememberedEmailUseCase {
  final AuthRepo _repo;

  GetRememberedEmailUseCase(this._repo);

  Future<String?> call() => _repo.loadRememberedEmail();
}
