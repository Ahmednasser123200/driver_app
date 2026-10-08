import 'package:injectable/injectable.dart';
import '../../../../config/base/base_response.dart';
import '../entities/apply_entity/country_entity.dart';
import '../repo/auth_repo.dart';

@injectable
class GetCountriesUseCase {
  final AuthRepo _repo;
  GetCountriesUseCase(this._repo);

  Future<BaseResponse<List<CountryEntity>>> execute() {
    return _repo.getCountries();
  }
}