import 'dart:async';

import 'package:driver_app/core/services/location/geolocator_wrapper.dart';
import 'package:driver_app/core/services/location/location_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockGeolocatorWrapper extends Mock implements GeolocatorWrapper {}

void main() {
  late MockGeolocatorWrapper wrapper;
  late LocationServiceImpl service;
  late StreamController<Position> geolocatorStreamController;

  setUpAll(() {
    registerFallbackValue(
      const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  });

  setUp(() {
    wrapper = MockGeolocatorWrapper();
    geolocatorStreamController = StreamController<Position>.broadcast();

    when(
      () => wrapper.getPositionStream(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenAnswer((_) => geolocatorStreamController.stream);

    when(
      () => wrapper.isLocationServiceEnabled(),
    ).thenAnswer((_) async => true);
    when(
      () => wrapper.checkPermission(),
    ).thenAnswer((_) async => LocationPermission.whileInUse);

    service = LocationServiceImpl(wrapper);
  });

  tearDown(() async {
    await geolocatorStreamController.close();
    await service.dispose();
  });

  group('Permission & Status checks', () {
    test('isLocationServiceEnabled forwards to wrapper', () async {
      when(
        () => wrapper.isLocationServiceEnabled(),
      ).thenAnswer((_) async => true);

      final result = await service.isLocationServiceEnabled();

      expect(result, isTrue);
      verify(() => wrapper.isLocationServiceEnabled()).called(1);
    });

    test('checkPermission forwards to wrapper', () async {
      when(
        () => wrapper.checkPermission(),
      ).thenAnswer((_) async => LocationPermission.always);

      final result = await service.checkPermission();

      expect(result, LocationPermission.always);
      verify(() => wrapper.checkPermission()).called(1);
    });

    test('requestPermission forwards to wrapper', () async {
      when(
        () => wrapper.requestPermission(),
      ).thenAnswer((_) async => LocationPermission.whileInUse);

      final result = await service.requestPermission();

      expect(result, LocationPermission.whileInUse);
      verify(() => wrapper.requestPermission()).called(1);
    });
  });

  group('checkAndRequestPermission', () {
    test('returns false when location service is disabled', () async {
      when(
        () => wrapper.isLocationServiceEnabled(),
      ).thenAnswer((_) async => false);

      final result = await service.checkAndRequestPermission();

      expect(result, isFalse);
    });

    test('returns false when permission is deniedForever', () async {
      when(
        () => wrapper.isLocationServiceEnabled(),
      ).thenAnswer((_) async => true);
      when(
        () => wrapper.checkPermission(),
      ).thenAnswer((_) async => LocationPermission.deniedForever);

      final result = await service.checkAndRequestPermission();

      expect(result, isFalse);
    });

    test(
      'returns false when permission is denied and request is denied',
      () async {
        when(
          () => wrapper.isLocationServiceEnabled(),
        ).thenAnswer((_) async => true);
        when(
          () => wrapper.checkPermission(),
        ).thenAnswer((_) async => LocationPermission.denied);
        when(
          () => wrapper.requestPermission(),
        ).thenAnswer((_) async => LocationPermission.denied);

        final result = await service.checkAndRequestPermission();

        expect(result, isFalse);
      },
    );

    test(
      'returns true when permission was denied but request is granted',
      () async {
        when(
          () => wrapper.isLocationServiceEnabled(),
        ).thenAnswer((_) async => true);
        when(
          () => wrapper.checkPermission(),
        ).thenAnswer((_) async => LocationPermission.denied);
        when(
          () => wrapper.requestPermission(),
        ).thenAnswer((_) async => LocationPermission.whileInUse);

        final result = await service.checkAndRequestPermission();

        expect(result, isTrue);
      },
    );

    test(
      'returns true immediately when permission is already granted',
      () async {
        when(
          () => wrapper.isLocationServiceEnabled(),
        ).thenAnswer((_) async => true);
        when(
          () => wrapper.checkPermission(),
        ).thenAnswer((_) async => LocationPermission.always);

        final result = await service.checkAndRequestPermission();

        expect(result, isTrue);
        verifyNever(() => wrapper.requestPermission());
      },
    );
  });

  group('getCurrentPosition', () {
    test(
      'returns position when permission is granted and wrapper succeeds',
      () async {
        final position = buildPositionFixture();
        when(
          () => wrapper.isLocationServiceEnabled(),
        ).thenAnswer((_) async => true);
        when(
          () => wrapper.checkPermission(),
        ).thenAnswer((_) async => LocationPermission.whileInUse);
        when(
          () => wrapper.getCurrentPosition(
            locationSettings: any(named: 'locationSettings'),
          ),
        ).thenAnswer((_) async => position);

        final result = await service.getCurrentPosition();

        expect(result, position);
      },
    );

    test('returns null when permission is denied', () async {
      when(
        () => wrapper.isLocationServiceEnabled(),
      ).thenAnswer((_) async => false);

      final result = await service.getCurrentPosition();

      expect(result, isNull);
    });

    test('returns null when wrapper throws exception', () async {
      when(
        () => wrapper.isLocationServiceEnabled(),
      ).thenAnswer((_) async => true);
      when(
        () => wrapper.checkPermission(),
      ).thenAnswer((_) async => LocationPermission.whileInUse);
      when(
        () => wrapper.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenThrow(Exception('GPS error'));

      final result = await service.getCurrentPosition();

      expect(result, isNull);
    });
  });

  group('locationStream', () {
    test('emits positions received from geolocator stream', () async {
      final emittedPositions = <Position>[];
      final subscription = service.locationStream.listen(emittedPositions.add);

      await pumpEventQueue();

      final p1 = buildPositionFixture(latitude: 30.1, longitude: 31.1);
      final p2 = buildPositionFixture(latitude: 30.2, longitude: 31.2);

      geolocatorStreamController.add(p1);
      geolocatorStreamController.add(p2);

      await pumpEventQueue();

      expect(emittedPositions, [p1, p2]);
      await subscription.cancel();
    });

    test('forwards errors from geolocator stream', () async {
      final errors = <dynamic>[];
      final subscription = service.locationStream.listen(
        (_) {},
        onError: errors.add,
      );

      await pumpEventQueue();

      geolocatorStreamController.addError('Location error');
      await pumpEventQueue();

      expect(errors, contains('Location error'));
      await subscription.cancel();
    });
  });
}
