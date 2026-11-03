import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/delivery_map/data/datasources/routing_remote_data_source.dart';
import 'package:driver_app/features/delivery_map/domain/models/route_model.dart';
import 'package:driver_app/features/delivery_map/domain/repository/routing_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: RoutingRepository)
class RoutingRepositoryImpl implements RoutingRepository {
  final RoutingRemoteDataSource remoteDataSource;
  final Map<String, RouteModel> _cache = <String, RouteModel>{};

  RoutingRepositoryImpl(this.remoteDataSource);

  String _buildCacheKey(LatLng origin, LatLng destination) {
    // Quantize coordinates to roughly ~30-50m grid to enable effective caching
    final oLat = (origin.latitude * 2000).round();
    final oLng = (origin.longitude * 2000).round();
    final dLat = (destination.latitude * 2000).round();
    final dLng = (destination.longitude * 2000).round();
    return '$oLat,$oLng->$dLat,$dLng';
  }

  @override
  Future<BaseResponse<RouteModel>> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final cacheKey = _buildCacheKey(origin, destination);
    final cached = _cache[cacheKey];
    if (cached != null) {
      return Success(cached);
    }

    try {
      final route = await remoteDataSource.fetchRoute(
        origin: origin,
        destination: destination,
      );

      _cache[cacheKey] = route;
      return Success(route);
    } on AppFailure catch (failure) {
      return Error(failure);
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  void clearCache() {
    _cache.clear();
  }
}
