import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/delivery_map/domain/models/route_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract interface class RoutingRepository {
  Future<BaseResponse<RouteModel>> getRoute({
    required LatLng origin,
    required LatLng destination,
  });
}
