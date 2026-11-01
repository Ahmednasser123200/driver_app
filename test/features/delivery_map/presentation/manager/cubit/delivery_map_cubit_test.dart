import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/core/services/location/location_service.dart';
import 'package:driver_app/features/delivery_map/domain/models/address_model.dart';
import 'package:driver_app/features/delivery_map/domain/models/delivery_map_target.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/get_driver_location_stream_use_case.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_cubit.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_event.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationService extends Mock implements LocationService {}

class MockGetDriverLocationStreamUseCase extends Mock
    implements GetDriverLocationStreamUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocationService mockLocationService;
  late MockGetDriverLocationStreamUseCase mockLocationStreamUseCase;
  late StreamController<Position> locationStreamController;
  late DeliveryMapCubit cubit;

  Position createPosition({
    double latitude = 30.0444,
    double longitude = 31.2357,
  }) {
    return Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now().toUtc(),
      accuracy: 5.0,
      altitude: 10.0,
      altitudeAccuracy: 1.0,
      heading: 0.0,
      headingAccuracy: 1.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }

  setUp(() {
    mockLocationService = MockLocationService();
    mockLocationStreamUseCase = MockGetDriverLocationStreamUseCase();
    locationStreamController = StreamController<Position>.broadcast();

    when(() => mockLocationStreamUseCase.call())
        .thenAnswer((_) => locationStreamController.stream);

    when(() => mockLocationService.checkAndRequestPermission())
        .thenAnswer((_) async => true);
    when(() => mockLocationService.getCurrentPosition())
        .thenAnswer((_) async => createPosition());

    cubit = DeliveryMapCubit(
      getDriverLocationStreamUseCase: mockLocationStreamUseCase,
      locationService: mockLocationService,
    );
  });

  tearDown(() async {
    await locationStreamController.close();
    await cubit.close();
  });

  group('DeliveryMapCubit', () {
    test('initial state is default DeliveryMapState', () {
      expect(cubit.state, const DeliveryMapState());
    });

    blocTest<DeliveryMapCubit, DeliveryMapState>(
      'InitDeliveryMapEvent initializes with custom addresses and starts tracking',
      build: () => cubit,
      act: (c) => c.doEvent(
        const InitDeliveryMapEvent(
          pickupAddress: AddressModel(
            title: 'Custom Store',
            addressLine: 'Custom Line',
            latitude: 30.1,
            longitude: 31.1,
          ),
          userAddress: AddressModel(
            title: 'Custom User',
            addressLine: 'User Line',
            latitude: 30.2,
            longitude: 31.2,
          ),
          initialTarget: DeliveryMapTarget.user,
        ),
      ),
      verify: (c) {
        expect(c.state.pickupAddress.title, 'Custom Store');
        expect(c.state.userAddress.title, 'Custom User');
        expect(c.state.target, DeliveryMapTarget.user);
        expect(c.state.hasLocationPermission, isTrue);
        expect(c.state.isTrackingLocation, isTrue);
        expect(c.state.driverPosition, const LatLng(30.0444, 31.2357));
        expect(c.state.markers, isNotEmpty);
        expect(c.state.polylines, isNotEmpty);
      },
    );

    blocTest<DeliveryMapCubit, DeliveryMapState>(
      'SwitchTargetEvent updates active target and rebuilds overlays',
      build: () => cubit,
      act: (c) async {
        await c.doEvent(const SwitchTargetEvent(DeliveryMapTarget.user));
        // Calling same target again should be a no-op
        await c.doEvent(const SwitchTargetEvent(DeliveryMapTarget.user));
      },
      verify: (c) {
        expect(c.state.target, DeliveryMapTarget.user);
        expect(c.state.markers, isNotEmpty);
        expect(c.state.polylines, isNotEmpty);
      },
    );

    test('StartDriverLocationTrackingEvent handles permission denied', () async {
      when(() => mockLocationService.checkAndRequestPermission())
          .thenAnswer((_) async => false);

      final events = <BaseUiEvent>[];
      final sub = cubit.uiEventStream.listen(events.add);

      await cubit.doEvent(const StartDriverLocationTrackingEvent());
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.hasLocationPermission, isFalse);
      expect(cubit.state.isTrackingLocation, isFalse);
      expect(events, contains(isA<DeliveryMapLocationPermissionDenied>()));

      await sub.cancel();
    });

    test('StartDriverLocationTrackingEvent receives stream error and emits UI event', () async {
      when(() => mockLocationService.checkAndRequestPermission())
          .thenAnswer((_) async => true);
      when(() => mockLocationService.getCurrentPosition())
          .thenAnswer((_) async => null);

      final events = <BaseUiEvent>[];
      final sub = cubit.uiEventStream.listen(events.add);

      await cubit.doEvent(const StartDriverLocationTrackingEvent());

      locationStreamController.addError(const LocationServiceDisabledException());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(events, contains(isA<DeliveryMapLocationServiceDisabled>()));

      await sub.cancel();
    });

    test('DriverPositionUpdatedEvent updates driver position and overlays', () async {
      await cubit.doEvent(
        DriverPositionUpdatedEvent(
          createPosition(latitude: 30.5555, longitude: 31.6666),
        ),
      );

      expect(
        cubit.state.driverPosition,
        const LatLng(30.5555, 31.6666),
      );
      expect(cubit.state.markers, isNotEmpty);
      expect(cubit.state.polylines, isNotEmpty);
    });

    test('StopDriverLocationTrackingEvent cancels tracking', () async {
      await cubit.doEvent(const StartDriverLocationTrackingEvent());
      expect(cubit.state.isTrackingLocation, isTrue);

      await cubit.doEvent(const StopDriverLocationTrackingEvent());
      expect(cubit.state.isTrackingLocation, isFalse);
    });

    test('CallPhoneEvent and OpenWhatsAppEvent handle null and blank inputs cleanly', () async {
      await cubit.doEvent(const CallPhoneEvent(null));
      await cubit.doEvent(const CallPhoneEvent('   '));
      await cubit.doEvent(const OpenWhatsAppEvent(null));
      await cubit.doEvent(const OpenWhatsAppEvent('   '));

      expect(cubit.state.errorMessage, isNull);
    });
  });
}
