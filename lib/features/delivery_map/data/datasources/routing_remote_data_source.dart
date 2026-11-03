import 'package:dio/dio.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/core/constants/api_strings/api_strings.dart';
import 'package:driver_app/features/delivery_map/domain/models/route_model.dart';
import 'package:driver_app/features/delivery_map/presentation/utils/polyline_decoder.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';

abstract interface class RoutingRemoteDataSource {
  Future<RouteModel> fetchRoute({
    required LatLng origin,
    required LatLng destination,
  });
}

@LazySingleton(as: RoutingRemoteDataSource)
class RoutingRemoteDataSourceImpl implements RoutingRemoteDataSource {
  final Dio dio;
  final String? apiKey;

  @factoryMethod
  RoutingRemoteDataSourceImpl()
      : dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 8),
          ),
        ),
        apiKey = null;

  RoutingRemoteDataSourceImpl.withDio({
    required this.dio,
    this.apiKey,
  });

  String get _effectiveApiKey => apiKey ?? ApiStrings.googleMapsApiKey;

  @override
  Future<RouteModel> fetchRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    // 1. Try Google Routes / Directions API if API key is present
    if (_effectiveApiKey.isNotEmpty) {
      try {
        final googleRoute = await _fetchGoogleRoutes(origin, destination);
        if (googleRoute != null) {
          return googleRoute;
        }
      } catch (e) {
        debugPrint(
            'RoutingRemoteDataSource: Google Routes failed: $e, falling back to OSRM');
      }

      try {
        final legacyRoute =
            await _fetchGoogleDirectionsLegacy(origin, destination);
        if (legacyRoute != null) {
          return legacyRoute;
        }
      } catch (e) {
        debugPrint(
            'RoutingRemoteDataSource: Google Legacy Directions failed: $e, falling back to OSRM');
      }
    }

    // 2. Resilient Fallback: OSRM (Open Source Routing Machine)
    try {
      return await _fetchOsrmRoute(origin, destination);
    } on AppFailure {
      rethrow;
    } on DioException catch (dioError) {
      debugPrint(
          'RoutingRemoteDataSource: OSRM request failed: ${dioError.message}');
      throw _mapDioException(dioError);
    } catch (e) {
      debugPrint('RoutingRemoteDataSource: Unexpected error: $e');
      throw const UnknownFailure();
    }
  }

  Future<RouteModel?> _fetchGoogleRoutes(
      LatLng origin, LatLng destination) async {
    final response = await dio.post<Map<String, dynamic>>(
      'https://routes.googleapis.com/directions/v2:computeRoutes',
      options: Options(
        headers: <String, String>{
          'X-Goog-Api-Key': _effectiveApiKey,
          'X-Goog-FieldMask':
              'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
          'Content-Type': 'application/json',
        },
      ),
      data: <String, dynamic>{
        'origin': <String, dynamic>{
          'location': <String, dynamic>{
            'latLng': <String, dynamic>{
              'latitude': origin.latitude,
              'longitude': origin.longitude,
            },
          },
        },
        'destination': <String, dynamic>{
          'location': <String, dynamic>{
            'latLng': <String, dynamic>{
              'latitude': destination.latitude,
              'longitude': destination.longitude,
            },
          },
        },
        'travelMode': 'DRIVE',
      },
    );

    final data = response.data;
    if (data == null || !data.containsKey('routes')) return null;

    final routes = data['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) return null;

    final firstRoute = routes.first as Map<String, dynamic>;
    final polylineObj = firstRoute['polyline'] as Map<String, dynamic>?;
    final encoded = polylineObj?['encodedPolyline'] as String?;
    if (encoded == null || encoded.isEmpty) return null;

    final points = PolylineDecoder.decode(encoded);
    if (points.isEmpty) return null;

    final distanceMeters =
        (firstRoute['distanceMeters'] as num?)?.toDouble() ?? 0.0;
    final durationStr = firstRoute['duration'] as String? ?? '0s';
    final durationSeconds =
        double.tryParse(durationStr.replaceAll('s', '')) ?? 0.0;

    return RouteModel(
      points: points,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      encodedPolyline: encoded,
    );
  }

  Future<RouteModel?> _fetchGoogleDirectionsLegacy(
      LatLng origin, LatLng destination) async {
    final response = await dio.get<Map<String, dynamic>>(
      'https://maps.googleapis.com/maps/api/directions/json',
      queryParameters: <String, dynamic>{
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'mode': 'driving',
        'key': _effectiveApiKey,
      },
    );

    final data = response.data;
    if (data == null || data['status'] != 'OK') return null;

    final routes = data['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) return null;

    final firstRoute = routes.first as Map<String, dynamic>;
    final overviewPolyline =
        firstRoute['overview_polyline'] as Map<String, dynamic>?;
    final encoded = overviewPolyline?['points'] as String?;
    if (encoded == null || encoded.isEmpty) return null;

    final points = PolylineDecoder.decode(encoded);
    if (points.isEmpty) return null;

    double distanceMeters = 0.0;
    double durationSeconds = 0.0;

    final legs = firstRoute['legs'] as List<dynamic>?;
    if (legs != null && legs.isNotEmpty) {
      final leg = legs.first as Map<String, dynamic>;
      final distObj = leg['distance'] as Map<String, dynamic>?;
      distanceMeters = (distObj?['value'] as num?)?.toDouble() ?? 0.0;

      final durObj = leg['duration'] as Map<String, dynamic>?;
      durationSeconds = (durObj?['value'] as num?)?.toDouble() ?? 0.0;
    }

    return RouteModel(
      points: points,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      encodedPolyline: encoded,
    );
  }

  Future<RouteModel> _fetchOsrmRoute(LatLng origin, LatLng destination) async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson';

    final response = await dio.get<Map<String, dynamic>>(url);
    final data = response.data;

    if (data == null || data['code'] != 'Ok') {
      throw const ServerFailure();
    }

    final routes = data['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      throw const NotFoundFailure();
    }

    final firstRoute = routes.first as Map<String, dynamic>;
    final geometry = firstRoute['geometry'] as Map<String, dynamic>?;
    final rawCoordinates = geometry?['coordinates'] as List<dynamic>?;

    if (rawCoordinates == null || rawCoordinates.isEmpty) {
      throw const NotFoundFailure();
    }

    final points = rawCoordinates.map((coord) {
      final pair = coord as List<dynamic>;
      final lng = (pair[0] as num).toDouble();
      final lat = (pair[1] as num).toDouble();
      return LatLng(lat, lng);
    }).toList();

    final distanceMeters = (firstRoute['distance'] as num?)?.toDouble() ?? 0.0;
    final durationSeconds = (firstRoute['duration'] as num?)?.toDouble() ?? 0.0;

    return RouteModel(
      points: points,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
    );
  }

  AppFailure _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
        return const InternetConnectionFailure();
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 400) return const BadRequestFailure();
        if (code == 401) return const UnauthorizedFailure();
        if (code == 403) return const ForbiddenFailure();
        if (code == 404) return const NotFoundFailure();
        return ServerFailure(statusCode: code);
      case DioExceptionType.cancel:
        return const CancelFailure();
      case DioExceptionType.badCertificate:
        return const BadCertificateFailure();
      case DioExceptionType.unknown:
        return const UnknownFailure();
    }
  }
}
