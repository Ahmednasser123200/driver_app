import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/pickup_location/domain/entities/driving_route.dart';
import 'package:driver_app/features/pickup_location/domain/entities/map_location.dart';
import 'package:driver_app/features/pickup_location/domain/params/driving_route_params.dart';
import 'package:driver_app/features/pickup_location/domain/repo/pickup_location_repo.dart';
import 'package:driver_app/features/pickup_location/domain/usecases/get_driving_route_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures.dart';

class MockPickupLocationRepo extends Mock implements PickupLocationRepo {}

void main() {
  late MockPickupLocationRepo repository;
  late GetDrivingRouteUseCase useCase;

  setUp(() {
    repository = MockPickupLocationRepo();
    useCase = GetDrivingRouteUseCase(repository);

    registerFallbackValue(kDrivingRouteParams);
  });

  test('calls the repository when the coordinates are valid', () async {
    when(
      () => repository.getDrivingRoute(any()),
    ).thenAnswer((_) async => Success<DrivingRoute>(buildDrivingRoute()));

    final result = await useCase.execute(kDrivingRouteParams);

    expect(result, isA<Success<DrivingRoute>>());
    expect((result as Success<DrivingRoute>).data, equals(buildDrivingRoute()));
    verify(() => repository.getDrivingRoute(kDrivingRouteParams)).called(1);
  });

  test('does not call the repository when the origin is invalid', () async {
    final params = DrivingRouteParams(
      origin: const MapLocation(latitude: 0, longitude: 0),
      destination: kCustomerLocation,
    );

    final result = await useCase.execute(params);

    expect(result, isA<Error<DrivingRoute>>());
    expect((result as Error<DrivingRoute>).failure, isA<BadRequestFailure>());
    verifyNever(() => repository.getDrivingRoute(any()));
  });

  test(
    'does not call the repository when the destination latitude is out of range',
    () async {
      final params = DrivingRouteParams(
        origin: kPickupLocation,
        destination: const MapLocation(latitude: 95, longitude: 31.2302),
      );

      final result = await useCase.execute(params);

      expect(result, isA<Error<DrivingRoute>>());
      expect((result as Error<DrivingRoute>).failure, isA<BadRequestFailure>());
      verifyNever(() => repository.getDrivingRoute(any()));
    },
  );

  test(
    'does not call the repository when the destination longitude is out of range',
    () async {
      final params = DrivingRouteParams(
        origin: kPickupLocation,
        destination: const MapLocation(latitude: 30.0398, longitude: -200),
      );

      final result = await useCase.execute(params);

      expect(result, isA<Error<DrivingRoute>>());
      expect((result as Error<DrivingRoute>).failure, isA<BadRequestFailure>());
      verifyNever(() => repository.getDrivingRoute(any()));
    },
  );

  test('propagates the failure returned by the repository', () async {
    when(
      () => repository.getDrivingRoute(any()),
    ).thenAnswer((_) async => Error<DrivingRoute>(const UnknownFailure()));

    final result = await useCase.execute(kDrivingRouteParams);

    expect(result, isA<Error<DrivingRoute>>());
    expect((result as Error<DrivingRoute>).failure, isA<UnknownFailure>());
  });
}
