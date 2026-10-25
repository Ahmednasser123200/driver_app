import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/pickup_location/data/dtos/responses/driving_route_response_dto.dart';
import 'package:driver_app/features/pickup_location/domain/params/driving_route_params.dart';

abstract interface class PickupLocationRemoteDataSource {
  Future<BaseResponse<DrivingRouteResponseDto>> getDrivingRoute(
    DrivingRouteParams params,
  );
}
