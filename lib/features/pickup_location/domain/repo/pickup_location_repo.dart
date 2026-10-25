import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/pickup_location/domain/entities/driving_route.dart';
import 'package:driver_app/features/pickup_location/domain/params/driving_route_params.dart';

abstract interface class PickupLocationRepo {
  Future<BaseResponse<DrivingRoute>> getDrivingRoute(DrivingRouteParams params);
}
