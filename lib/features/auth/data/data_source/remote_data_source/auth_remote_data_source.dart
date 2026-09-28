import 'package:driver_app/config/base/base_response.dart';

import '../../model/request/apply_request/application_request_dto.dart';
import '../../model/response/apply_response/application_response_dto.dart';

abstract interface class AuthRemoteDataSource {
  Future<BaseResponse<ApplicationResponseDto>> addApplication(
      ApplicationRequestDto request);
}