import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/pickup_location/data/datasources/pickup_location_remote_data_source.dart';
import 'package:driver_app/features/pickup_location/data/dtos/responses/driving_route_response_dto.dart';
import 'package:driver_app/features/pickup_location/domain/entities/driving_route.dart';
import 'package:driver_app/features/pickup_location/domain/params/driving_route_params.dart';
import 'package:driver_app/features/pickup_location/domain/repo/pickup_location_repo.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: PickupLocationRepo)
class PickupLocationRepoImpl implements PickupLocationRepo {
  PickupLocationRepoImpl(this._remoteDataSource);

  final PickupLocationRemoteDataSource _remoteDataSource;

  @override
  Future<BaseResponse<DrivingRoute>> getDrivingRoute(
    DrivingRouteParams params,
  ) async {
    final result = await _remoteDataSource.getDrivingRoute(params);

    return switch (result) {
      Success<DrivingRouteResponseDto>(data: final data) => _mapRoute(data),
      Error<DrivingRouteResponseDto>(failure: final failure) =>
        Error<DrivingRoute>(failure),
    };
  }

  BaseResponse<DrivingRoute> _mapRoute(DrivingRouteResponseDto response) {
    if (!response.isOk || response.routeList.isEmpty) {
      return const Error<DrivingRoute>(NotFoundFailure());
    }

    final route = response.routeList.first.toDomain();

    if (route.isEmpty) {
      return const Error<DrivingRoute>(NotFoundFailure());
    }

    return Success<DrivingRoute>(route);
  }
}
