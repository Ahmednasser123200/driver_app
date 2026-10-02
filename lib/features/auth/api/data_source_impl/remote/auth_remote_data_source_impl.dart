import 'package:injectable/injectable.dart';

import '../../../data/data_source/remote_data_source/auth_remote_data_source.dart';
import '../../../data/model/request/login_request/login_request.dart';
import '../../../data/model/response/login_response/login_response.dart';
import '../../client/auth_api_client.dart';

@Injectable(as: AuthRemoteDataSource)
class RemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthApiClient _authApiClient;

  RemoteDataSourceImpl(this._authApiClient);

  @override
  Future<LoginResponse> login(LoginRequest login) async {
    return await _authApiClient.login(login);
  }
}