import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/delivery_map/domain/models/geo_point.dart';
import 'package:driver_app/features/delivery_map/domain/models/route_model.dart';
import 'package:driver_app/features/delivery_map/domain/repository/routing_repository.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/get_route_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRoutingRepository extends Mock implements RoutingRepository {}

void main() {
  late MockRoutingRepository mockRepository;
  late GetRouteUseCase useCase;

  const origin = GeoPoint(latitude: 30.0190, longitude: 31.2140);
  const destination = GeoPoint(latitude: 30.0250, longitude: 31.2200);

  const sampleRoute = RouteModel(
    points: <GeoPoint>[origin, destination],
    distanceMeters: 1200.0,
    durationSeconds: 240.0,
  );

  setUp(() {
    mockRepository = MockRoutingRepository();
    useCase = GetRouteUseCase(mockRepository);
  });

  group('GetRouteUseCase', () {
    test('forwards call to repository and returns Success on route found', () async {
      when(
        () => mockRepository.getRoute(
          origin: origin,
          destination: destination,
        ),
      ).thenAnswer((_) async => const Success(sampleRoute));

      final result = await useCase(
        origin: origin,
        destination: destination,
      );

      expect(result, isA<Success<RouteModel>>());
      final success = result as Success<RouteModel>;
      expect(success.data, sampleRoute);
      verify(
        () => mockRepository.getRoute(
          origin: origin,
          destination: destination,
        ),
      ).called(1);
    });

    test('forwards call to repository and returns Error on failure', () async {
      when(
        () => mockRepository.getRoute(
          origin: origin,
          destination: destination,
        ),
      ).thenAnswer((_) async => const Error(InternetConnectionFailure()));

      final result = await useCase(
        origin: origin,
        destination: destination,
      );

      expect(result, isA<Error<RouteModel>>());
      final error = result as Error<RouteModel>;
      expect(error.failure, isA<InternetConnectionFailure>());
    });
  });
}
