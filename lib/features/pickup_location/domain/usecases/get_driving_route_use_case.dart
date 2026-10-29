import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/pickup_location/domain/entities/driving_route.dart';
import 'package:driver_app/features/pickup_location/domain/params/driving_route_params.dart';
import 'package:driver_app/features/pickup_location/domain/repo/pickup_location_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetDrivingRouteUseCase {
  GetDrivingRouteUseCase(this._repository);

  final PickupLocationRepo _repository;

 
  Future<BaseResponse<DrivingRoute>> execute(DrivingRouteParams params) {
    if (!params.origin.isValid || !params.destination.isValid) {
      return Future<BaseResponse<DrivingRoute>>.value(
        const Error<DrivingRoute>(BadRequestFailure()),
      );
    }

    return _repository.getDrivingRoute(params);
  }
}
