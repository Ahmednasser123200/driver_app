import 'package:dio/dio.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/dio/dio_failure_mapper.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/pickup_location/api/client/pickup_location_api_client.dart';
import 'package:driver_app/features/pickup_location/data/datasources/pickup_location_remote_data_source.dart';
import 'package:driver_app/features/pickup_location/data/dtos/responses/driving_route_response_dto.dart';
import 'package:driver_app/features/pickup_location/domain/params/driving_route_params.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: PickupLocationRemoteDataSource)
class PickupLocationRemoteDataSourceImpl
    implements PickupLocationRemoteDataSource {
  PickupLocationRemoteDataSourceImpl(this._apiClient);

  final PickupLocationApiClient _apiClient;

  static const String _overview = 'full';
  static const String _geometries = 'geojson';

  @override
  Future<BaseResponse<DrivingRouteResponseDto>> getDrivingRoute(
    DrivingRouteParams params,
  ) async {
    final coordinates =
        '${params.origin.longitude},${params.origin.latitude};'
        '${params.destination.longitude},${params.destination.latitude}';

    try {
      final response = await _apiClient.getDrivingRoute(
        coordinates,
        overview: _overview,
        geometries: _geometries,
      );

      return Success<DrivingRouteResponseDto>(response);
    } on DioException catch (error) {
      return Error<DrivingRouteResponseDto>(mapDioExceptionToAppFailure(error));
    } catch (_) {
      return Error<DrivingRouteResponseDto>(const UnknownFailure());
    }
  }
}
