import 'dart:collection';

import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/delivery_map/data/datasources/routing_remote_data_source.dart';
import 'package:driver_app/features/delivery_map/data/dtos/requests/compute_routes_request_dto.dart';
import 'package:driver_app/features/delivery_map/data/dtos/responses/compute_routes_response_dto.dart';
import 'package:driver_app/features/delivery_map/domain/models/geo_point.dart';
import 'package:driver_app/features/delivery_map/domain/models/route_model.dart';
import 'package:driver_app/features/delivery_map/domain/repository/routing_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: RoutingRepository)
class RoutingRepositoryImpl implements RoutingRepository {
  static const int defaultMaxCacheEntries = 30;

  final RoutingRemoteDataSource remoteDataSource;
  final int maxCacheEntries;
  final LinkedHashMap<String, RouteModel> _cache =
      LinkedHashMap<String, RouteModel>();

  RoutingRepositoryImpl(
    this.remoteDataSource, {
    @ignoreParam this.maxCacheEntries = defaultMaxCacheEntries,
  });

  int get cacheSize => _cache.length;

  String _buildCacheKey(GeoPoint origin, GeoPoint destination) {
    // Quantize coordinates to roughly ~30-50m grid to enable effective caching
    final oLat = (origin.latitude * 2000).round();
    final oLng = (origin.longitude * 2000).round();
    final dLat = (destination.latitude * 2000).round();
    final dLng = (destination.longitude * 2000).round();
    return '$oLat,$oLng->$dLat,$dLng';
  }

  void _putInCache(String key, RouteModel route) {
    if (maxCacheEntries <= 0) return;

    _cache.remove(key);
    while (_cache.length >= maxCacheEntries) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = route;
  }

  @override
  Future<BaseResponse<RouteModel>> getRoute({
    required GeoPoint origin,
    required GeoPoint destination,
  }) async {
    final cacheKey = _buildCacheKey(origin, destination);
    final cached = _cache.remove(cacheKey);
    if (cached != null) {
      // Refresh LRU ordering
      _cache[cacheKey] = cached;
      return Success(cached);
    }

    final request = ComputeRoutesRequestDto.fromCoordinates(
      origin: origin,
      destination: destination,
    );

    final response = await remoteDataSource.fetchRoute(request);

    switch (response) {
      case Success<ComputeRoutesResponseDto>(:final data):
        final route = data.toDomain();
        if (route == null) {
          return const Error(NotFoundFailure());
        }
        _putInCache(cacheKey, route);
        return Success(route);
      case Error<ComputeRoutesResponseDto>(:final failure):
        return Error(failure);
    }
  }

  void clearCache() {
    _cache.clear();
  }
}
