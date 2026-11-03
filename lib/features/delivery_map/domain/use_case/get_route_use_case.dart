import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/delivery_map/domain/models/route_model.dart';
import 'package:driver_app/features/delivery_map/domain/repository/routing_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetRouteUseCase {
  final RoutingRepository _repository;

  const GetRouteUseCase(this._repository);

  Future<BaseResponse<RouteModel>> call({
    required LatLng origin,
    required LatLng destination,
  }) {
    return _repository.getRoute(
      origin: origin,
      destination: destination,
    );
  }
}
