import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/pickup_location/data/datasources/pickup_location_remote_data_source.dart';
import 'package:driver_app/features/pickup_location/data/dtos/responses/driving_route_response_dto.dart';
import 'package:driver_app/features/pickup_location/data/repo/pickup_location_repo_impl.dart';
import 'package:driver_app/features/pickup_location/domain/entities/driving_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures.dart';

class MockPickupLocationRemoteDataSource extends Mock
    implements PickupLocationRemoteDataSource {}

void main() {
  late MockPickupLocationRemoteDataSource remoteDataSource;
  late PickupLocationRepoImpl repository;

  setUp(() {
    remoteDataSource = MockPickupLocationRemoteDataSource();
    repository = PickupLocationRepoImpl(remoteDataSource);

    registerFallbackValue(kDrivingRouteParams);
  });

  test('maps the response of the data source to a domain route', () async {
    when(() => remoteDataSource.getDrivingRoute(any())).thenAnswer(
      (_) async =>
          Success<DrivingRouteResponseDto>(buildDrivingRouteResponseDto()),
    );

    final result = await repository.getDrivingRoute(kDrivingRouteParams);

    expect(result, isA<Success<DrivingRoute>>());
    expect((result as Success<DrivingRoute>).data, equals(buildDrivingRoute()));
  });

  test(
    'fails with a not found failure when the service has no route',
    () async {
      when(() => remoteDataSource.getDrivingRoute(any())).thenAnswer(
        (_) async => Success<DrivingRouteResponseDto>(
          DrivingRouteResponseDto.fromJson(<String, dynamic>{
            'code': 'NoRoute',
          }),
        ),
      );

      final result = await repository.getDrivingRoute(kDrivingRouteParams);

      expect(result, isA<Error<DrivingRoute>>());
      expect((result as Error<DrivingRoute>).failure, isA<NotFoundFailure>());
    },
  );

  test('fails with a not found failure when the route has no points', () async {
    when(() => remoteDataSource.getDrivingRoute(any())).thenAnswer(
      (_) async => Success<DrivingRouteResponseDto>(
        DrivingRouteResponseDto.fromJson(<String, dynamic>{
          'code': 'Ok',
          'routes': [
            <String, dynamic>{'distance': 100.0, 'duration': 50.0},
          ],
        }),
      ),
    );

    final result = await repository.getDrivingRoute(kDrivingRouteParams);

    expect(result, isA<Error<DrivingRoute>>());
    expect((result as Error<DrivingRoute>).failure, isA<NotFoundFailure>());
  });

  test('propagates the failure returned by the data source', () async {
    when(() => remoteDataSource.getDrivingRoute(any())).thenAnswer(
      (_) async => Error<DrivingRouteResponseDto>(const UnknownFailure()),
    );

    final result = await repository.getDrivingRoute(kDrivingRouteParams);

    expect(result, isA<Error<DrivingRoute>>());
    expect((result as Error<DrivingRoute>).failure, isA<UnknownFailure>());
  });
}
