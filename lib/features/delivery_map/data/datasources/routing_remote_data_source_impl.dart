import 'package:dio/dio.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/dio/dio_failure_mapper.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/delivery_map/api/client/routing_api_client.dart';
import 'package:driver_app/features/delivery_map/data/datasources/routing_remote_data_source.dart';
import 'package:driver_app/features/delivery_map/data/dtos/requests/compute_routes_request_dto.dart';
import 'package:driver_app/features/delivery_map/data/dtos/responses/compute_routes_response_dto.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: RoutingRemoteDataSource)
class RoutingRemoteDataSourceImpl implements RoutingRemoteDataSource {
  final RoutingApiClient _apiClient;

  const RoutingRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<ComputeRoutesResponseDto>> fetchRoute(
    ComputeRoutesRequestDto request,
  ) async {
    try {
      final response = await _apiClient.computeRoutes(request);
      return Success<ComputeRoutesResponseDto>(response);
    } on DioException catch (error) {
      return Error<ComputeRoutesResponseDto>(
        mapDioExceptionToAppFailure(error),
      );
    } catch (_) {
      return const Error<ComputeRoutesResponseDto>(UnknownFailure());
    }
  }
}
