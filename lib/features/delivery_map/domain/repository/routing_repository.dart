import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/delivery_map/domain/models/geo_point.dart';
import 'package:driver_app/features/delivery_map/domain/models/route_model.dart';

abstract interface class RoutingRepository {
  Future<BaseResponse<RouteModel>> getRoute({
    required GeoPoint origin,
    required GeoPoint destination,
  });
}
