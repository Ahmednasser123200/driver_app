import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/features/delivery_map/data/dtos/requests/compute_routes_request_dto.dart';
import 'package:driver_app/features/delivery_map/data/dtos/responses/compute_routes_response_dto.dart';

abstract interface class RoutingRemoteDataSource {
  Future<BaseResponse<ComputeRoutesResponseDto>> fetchRoute(
    ComputeRoutesRequestDto request,
  );
}
