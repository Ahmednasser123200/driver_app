import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/delivery_map/data/datasources/routing_remote_data_source.dart';
import 'package:driver_app/features/delivery_map/data/repository/routing_repository_impl.dart';
import 'package:driver_app/features/delivery_map/domain/models/route_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockRoutingRemoteDataSource extends Mock
    implements RoutingRemoteDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(const LatLng(0, 0));
  });

  late MockRoutingRemoteDataSource mockRemoteDataSource;
  late RoutingRepositoryImpl repository;

  const origin = LatLng(30.0190, 31.2140);
  const destination = LatLng(30.0250, 31.2200);

  const sampleRoute = RouteModel(
    points: <LatLng>[origin, destination],
    distanceMeters: 1000.0,
    durationSeconds: 120.0,
  );

  setUp(() {
    mockRemoteDataSource = MockRoutingRemoteDataSource();
    repository = RoutingRepositoryImpl(mockRemoteDataSource);
  });

  group('RoutingRepositoryImpl', () {
    test('calls remote data source on cache miss and returns Success', () async {
      when(
        () => mockRemoteDataSource.fetchRoute(
          origin: origin,
          destination: destination,
        ),
      ).thenAnswer((_) async => sampleRoute);

      final result = await repository.getRoute(
        origin: origin,
        destination: destination,
      );

      expect(result, isA<Success<RouteModel>>());
      final success = result as Success<RouteModel>;
      expect(success.data, sampleRoute);
      verify(
        () => mockRemoteDataSource.fetchRoute(
          origin: origin,
          destination: destination,
        ),
      ).called(1);
    });

    test('returns cached route on subsequent call without invoking remote data source', () async {
      when(
        () => mockRemoteDataSource.fetchRoute(
          origin: origin,
          destination: destination,
        ),
      ).thenAnswer((_) async => sampleRoute);

      // First call -> Cache miss
      await repository.getRoute(origin: origin, destination: destination);

      // Second call -> Cache hit
      final cachedResult =
          await repository.getRoute(origin: origin, destination: destination);

      expect(cachedResult, isA<Success<RouteModel>>());
      // verify remote was called ONLY once
      verify(
        () => mockRemoteDataSource.fetchRoute(
          origin: origin,
          destination: destination,
        ),
      ).called(1);
    });

    test('clearCache invalidates cached route', () async {
      when(
        () => mockRemoteDataSource.fetchRoute(
          origin: origin,
          destination: destination,
        ),
      ).thenAnswer((_) async => sampleRoute);

      await repository.getRoute(origin: origin, destination: destination);
      repository.clearCache();
      await repository.getRoute(origin: origin, destination: destination);

      verify(
        () => mockRemoteDataSource.fetchRoute(
          origin: origin,
          destination: destination,
        ),
      ).called(2);
    });

    test('returns Error when remote data source throws AppFailure', () async {
      when(
        () => mockRemoteDataSource.fetchRoute(
          origin: origin,
          destination: destination,
        ),
      ).thenThrow(const InternetConnectionFailure());

      final result = await repository.getRoute(
        origin: origin,
        destination: destination,
      );

      expect(result, isA<Error<RouteModel>>());
      final error = result as Error<RouteModel>;
      expect(error.failure, isA<InternetConnectionFailure>());
    });

    test('returns Error with UnknownFailure on generic unexpected exception', () async {
      when(
        () => mockRemoteDataSource.fetchRoute(
          origin: origin,
          destination: destination,
        ),
      ).thenThrow(Exception('Unknown system crash'));

      final result = await repository.getRoute(
        origin: origin,
        destination: destination,
      );

      expect(result, isA<Error<RouteModel>>());
      final error = result as Error<RouteModel>;
      expect(error.failure, isA<UnknownFailure>());
    });
  });
}
