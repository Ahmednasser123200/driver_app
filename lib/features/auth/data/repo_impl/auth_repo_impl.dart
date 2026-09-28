import 'package:driver_app/config/base/base_response.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/apply_entity/applications_entity.dart';
import '../../domain/repo/auth_repo.dart';
import '../data_source/remote_data_source/auth_remote_data_source.dart';
import '../model/request/apply_request/application_request_dto.dart';
import '../model/response/apply_response/application_response_dto.dart';

@Injectable(as: AuthRepo)
class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepoImpl(this._remoteDataSource);

  @override
  Future<BaseResponse<void>> addApplication(
      ApplicationEntity application) async {
    final response = await _remoteDataSource
        .addApplication(ApplicationRequestDto.fromEntity(application));

    switch (response) {
      case Success<ApplicationResponseDto>():
        return const Success<void>(null);
      case Error<ApplicationResponseDto>():
        return Error<void>(response.failure);
    }
  }
}