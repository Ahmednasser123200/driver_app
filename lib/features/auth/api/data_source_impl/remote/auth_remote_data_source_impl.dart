import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/execute_api.dart';
import 'package:injectable/injectable.dart';

import '../../../data/data_source/remote_data_source/auth_remote_data_source.dart';
import '../../../data/model/request/apply_request/application_request_dto.dart';
import '../../../data/model/response/apply_response/application_response_dto.dart';
import '../../client/auth_client.dart';


@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<BaseResponse<ApplicationResponseDto>> addApplication(
      ApplicationRequestDto request) {
    return executeApi(
          () => _client.addApplication(
        request.countryCode,
        request.firstName,
        request.secondName,
        request.vehicleType,
        request.vehicleNumber,
        request.email,
        request.phoneNumber,
        request.nationalId,
        request.password,
        request.confirmPassword,
        request.gender,
        request.vehicleLicenceFile,
        request.idImage,
      ),
    );
  }
}