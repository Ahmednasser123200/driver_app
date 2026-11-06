import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/delivery_map/data/datasources/routing_remote_data_source.dart';
import 'package:driver_app/features/delivery_map/data/dtos/requests/compute_routes_request_dto.dart';
import 'package:driver_app/features/delivery_map/data/dtos/responses/compute_routes_response_dto.dart';
import 'package:driver_app/features/delivery_map/data/repository/routing_repository_impl.dart';
import 'package:driver_app/features/delivery_map/domain/models/geo_point.dart';
import 'package:driver_app/features/delivery_map/domain/models/route_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRoutingRemoteDataSource extends Mock
    implements RoutingRemoteDataSource {}

void main() {
  const origin = GeoPoint(latitude: 30.0190, longitude: 31.2140);
  const destination = GeoPoint(latitude: 30.0250, longitude: 31.2200);

  setUpAll(() {
    registerFallbackValue(
      ComputeRoutesRequestDto.fromCoordinates(
        origin: origin,
        destination: destination,
      ),
    );
  });

  late MockRoutingRemoteDataSource mockRemoteDataSource;
  late RoutingRepositoryImpl repository;

  const sampleResponseDto = ComputeRoutesResponseDto(
    routes: [
      ComputedRouteDto(
        distanceMeters: 1000.0,
        duration: '120s',
        polyline: RoutePolylineDto(encodedPolyline: '_p~iF~ps|U_ulLnnqC'),
      ),
    ],
  );

  setUp(() {
    mockRemoteDataSource = MockRoutingRemoteDataSource();
    repository = RoutingRepositoryImpl(mockRemoteDataSource);
  });

  group('RoutingRepositoryImpl', () {
    test('calls remote data source on cache miss and maps DTO to RouteModel', () async {
      when(
        () => mockRemoteDataSource.fetchRoute(any()),
      ).thenAnswer((_) async => const Success(sampleResponseDto));

      final result = await repository.getRoute(
        origin: origin,
        destination: destination,
      );

      expect(result, isA<Success<RouteModel>>());
      final success = result as Success<RouteModel>;
      expect(success.data.distanceMeters, 1000.0);
      expect(success.data.durationSeconds, 120.0);
      expect(success.data.points, isNotEmpty);
      verify(() => mockRemoteDataSource.fetchRoute(any())).called(1);
    });

    test('returns cached route on subsequent call without invoking remote data source', () async {
      when(
        () => mockRemoteDataSource.fetchRoute(any()),
      ).thenAnswer((_) async => const Success(sampleResponseDto));

      await repository.getRoute(origin: origin, destination: destination);
      final cachedResult =
          await repository.getRoute(origin: origin, destination: destination);

      expect(cachedResult, isA<Success<RouteModel>>());
      verify(() => mockRemoteDataSource.fetchRoute(any())).called(1);
    });

    test('enforces maxCacheEntries limit with LRU eviction', () async {
      final boundedRepo = RoutingRepositoryImpl(
        mockRemoteDataSource,
        maxCacheEntries: 2,
      );

      when(
        () => mockRemoteDataSource.fetchRoute(any()),
      ).thenAnswer((_) async => const Success(sampleResponseDto));

      const p1 = GeoPoint(latitude: 30.01, longitude: 31.01);
      const p2 = GeoPoint(latitude: 30.05, longitude: 31.05);
      const p3 = GeoPoint(latitude: 30.10, longitude: 31.10);

      await boundedRepo.getRoute(origin: p1, destination: destination);
      await boundedRepo.getRoute(origin: p2, destination: destination);
      expect(boundedRepo.cacheSize, 2);

      // Refresh p1 so p2 becomes least-recently-used
      await boundedRepo.getRoute(origin: p1, destination: destination);

      // Adding p3 should evict p2 while keeping p1
      await boundedRepo.getRoute(origin: p3, destination: destination);
      expect(boundedRepo.cacheSize, 2);

      // p1 should still be cached (no additional remote call)
      await boundedRepo.getRoute(origin: p1, destination: destination);
      verify(() => mockRemoteDataSource.fetchRoute(any())).called(3);

      // p2 was evicted, so fetching it invokes remote again
      await boundedRepo.getRoute(origin: p2, destination: destination);
      verify(() => mockRemoteDataSource.fetchRoute(any())).called(1);
    });

    test('clearCache invalidates cached route', () async {
      when(
        () => mockRemoteDataSource.fetchRoute(any()),
      ).thenAnswer((_) async => const Success(sampleResponseDto));

      await repository.getRoute(origin: origin, destination: destination);
      repository.clearCache();
      await repository.getRoute(origin: origin, destination: destination);

      verify(() => mockRemoteDataSource.fetchRoute(any())).called(2);
    });

    test('returns Error(NotFoundFailure) when DTO has no valid routes', () async {
      when(
        () => mockRemoteDataSource.fetchRoute(any()),
      ).thenAnswer(
        (_) async => const Success(ComputeRoutesResponseDto(routes: [])),
      );

      final result = await repository.getRoute(
        origin: origin,
        destination: destination,
      );

      expect(result, isA<Error<RouteModel>>());
      expect((result as Error<RouteModel>).failure, isA<NotFoundFailure>());
    });

    test('propagates Error when remote data source returns Error', () async {
      when(
        () => mockRemoteDataSource.fetchRoute(any()),
      ).thenAnswer(
        (_) async => const Error(InternetConnectionFailure()),
      );

      final result = await repository.getRoute(
        origin: origin,
        destination: destination,
      );

      expect(result, isA<Error<RouteModel>>());
      expect(
        (result as Error<RouteModel>).failure,
        isA<InternetConnectionFailure>(),
      );
    });
  });
}
