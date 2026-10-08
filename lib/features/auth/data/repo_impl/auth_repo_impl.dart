import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/country_entity.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/vehicle_type_entity.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/apply_entity/applications_entity.dart';
import '../../domain/repo/auth_repo.dart';
import '../data_source/remote_data_source/auth_remote_data_source.dart';
import '../model/request/apply_request/application_request_dto.dart';
import '../model/response/apply_response/application_response_dto.dart';
import '../model/response/apply_response/country_dto.dart';
import '../model/response/apply_response/vehicle_type_dto.dart';

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
  @override
  Future<BaseResponse<List<CountryEntity>>> getCountries() async {
    final response = await _remoteDataSource.getCountries();
    switch (response) {
      case Success<List<CountryDto>>(:final data):
        return Success(data.map((e) => e.toEntity()).toList());
      case Error<List<CountryDto>>(:final failure):
        return Error(failure);
    }
  }

  @override
  Future<BaseResponse<List<VehicleTypeEntity>>> getVehicleTypes() async {
    final response = await _remoteDataSource.getVehicleTypes();
    switch (response) {
      case Success<List<VehicleTypeDto>>(:final data):
        return Success(data.map((e) => e.toEntity()).toList());
      case Error<List<VehicleTypeDto>>(:final failure):
        return Error(failure);
    }
  }
}