import 'package:dio/dio.dart';
import 'package:driver_app/features/delivery_map/data/dtos/requests/compute_routes_request_dto.dart';
import 'package:driver_app/features/delivery_map/data/dtos/responses/compute_routes_response_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'routing_api_client.g.dart';

@singleton
@RestApi()
abstract class RoutingApiClient {
  static const String routingBaseUrl = 'https://routes.googleapis.com';
  static const String computeRoutesPath = '/directions/v2:computeRoutes';
  static const String defaultFieldMask =
      'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline';

  @factoryMethod
  factory RoutingApiClient(@Named('googleRoutes') Dio dio) = _RoutingApiClient;

  @POST(computeRoutesPath)
  Future<ComputeRoutesResponseDto> computeRoutes(
    @Body() ComputeRoutesRequestDto request,
  );
}
