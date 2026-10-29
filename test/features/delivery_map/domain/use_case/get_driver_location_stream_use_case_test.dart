import 'dart:async';

import 'package:driver_app/core/services/location/location_service.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/get_driver_location_stream_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationService extends Mock implements LocationService {}

void main() {
  late MockLocationService mockLocationService;
  late StreamController<Position> locationStreamController;
  late GetDriverLocationStreamUseCase useCase;

  setUp(() {
    mockLocationService = MockLocationService();
    locationStreamController = StreamController<Position>.broadcast();
    when(() => mockLocationService.locationStream)
        .thenAnswer((_) => locationStreamController.stream);

    useCase = GetDriverLocationStreamUseCase(mockLocationService);
  });

  tearDown(() async {
    await locationStreamController.close();
  });

  Position createPosition({
    double latitude = 30.0444,
    double longitude = 31.2357,
    double heading = 90.0,
    double speed = 15.0,
  }) {
    return Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now().toUtc(),
      accuracy: 5.0,
      altitude: 10.0,
      altitudeAccuracy: 1.0,
      heading: heading,
      headingAccuracy: 1.0,
      speed: speed,
      speedAccuracy: 0.5,
    );
  }

  group('GetDriverLocationStreamUseCase', () {
    test('call returns the locationStream from LocationService', () {
      final expectedStream = locationStreamController.stream;
      final stream = useCase.call();

      expect(stream, equals(expectedStream));
      verify(() => mockLocationService.locationStream).called(1);
    });

    test('emits positions when the underlying location stream emits them',
        () async {
      final stream = useCase();
      final expectedPositions = [
        createPosition(latitude: 30.0444, longitude: 31.2357),
        createPosition(latitude: 30.0450, longitude: 31.2365),
      ];

      expectLater(stream, emitsInOrder(expectedPositions));

      for (final pos in expectedPositions) {
        locationStreamController.add(pos);
      }
    });

    test('propagates errors emitted by the location stream', () async {
      final stream = useCase();
      final error = const PermissionDeniedException('Location permission denied');

      expectLater(stream, emitsError(equals(error)));

      locationStreamController.addError(error);
    });

    test('supports multiple concurrent listeners without losing events',
        () async {
      final stream1 = useCase();
      final stream2 = useCase();
      final pos = createPosition();

      final expectation1 = expectLater(stream1, emits(pos));
      final expectation2 = expectLater(stream2, emits(pos));

      locationStreamController.add(pos);

      await Future.wait([expectation1, expectation2]);
    });

    test('emits done when underlying stream closes', () async {
      final stream = useCase();

      expectLater(stream, emitsDone);

      await locationStreamController.close();
    });
  });
}
