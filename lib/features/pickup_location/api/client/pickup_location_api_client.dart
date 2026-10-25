import 'package:dio/dio.dart';
import 'package:driver_app/features/pickup_location/data/dtos/responses/driving_route_response_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'pickup_location_api_client.g.dart';

/// Client of the public OSRM routing service.
@singleton
@RestApi(baseUrl: PickupLocationApiClient.routingBaseUrl)
abstract class PickupLocationApiClient {
  static const String routingBaseUrl = 'https://router.project-osrm.org';

  @factoryMethod
  factory PickupLocationApiClient(Dio dio) = _PickupLocationApiClient;

  @GET('/route/v1/driving/{coordinates}')
  Future<DrivingRouteResponseDto> getDrivingRoute(
    @Path('coordinates') String coordinates, {
    @Query('overview') required String overview,
    @Query('geometries') required String geometries,
  });
}
