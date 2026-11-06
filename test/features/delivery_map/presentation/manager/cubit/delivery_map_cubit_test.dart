import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/core/services/url_launcher/url_launcher_service.dart';
import 'package:driver_app/features/delivery_map/domain/models/address_model.dart';
import 'package:driver_app/features/delivery_map/domain/models/delivery_map_target.dart';
import 'package:driver_app/features/delivery_map/domain/models/geo_point.dart';
import 'package:driver_app/features/delivery_map/domain/models/route_model.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/check_location_permission_use_case.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/get_current_driver_location_use_case.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/get_driver_location_stream_use_case.dart';
import 'package:driver_app/features/delivery_map/domain/use_case/get_route_use_case.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_cubit.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_event.dart';
import 'package:driver_app/features/delivery_map/presentation/manager/cubit/delivery_map_state.dart';
import 'package:driver_app/features/order_details/domain/entities/user_location_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetDriverLocationStreamUseCase extends Mock
    implements GetDriverLocationStreamUseCase {}

class MockCheckLocationPermissionUseCase extends Mock
    implements CheckLocationPermissionUseCase {}

class MockGetCurrentDriverLocationUseCase extends Mock
    implements GetCurrentDriverLocationUseCase {}

class MockGetRouteUseCase extends Mock implements GetRouteUseCase {}

class MockUrlLauncherService extends Mock implements UrlLauncherService {}

void main() {
  late MockGetDriverLocationStreamUseCase mockLocationStreamUseCase;
  late MockCheckLocationPermissionUseCase mockCheckPermissionUseCase;
  late MockGetCurrentDriverLocationUseCase mockGetCurrentLocationUseCase;
  late MockGetRouteUseCase mockGetRouteUseCase;
  late MockUrlLauncherService mockUrlLauncherService;
  late StreamController<BaseResponse<UserLocationEntity>>
      locationStreamController;
  late DeliveryMapCubit cubit;

  const samplePickup = AddressModel(
    title: 'Custom Store',
    addressLine: 'Custom Line',
    latitude: 30.1,
    longitude: 31.1,
    phoneNumber: '+201000000000',
  );

  const sampleUser = AddressModel(
    title: 'Custom User',
    addressLine: 'User Line',
    latitude: 30.2,
    longitude: 31.2,
    phoneNumber: '+201011111111',
  );

  const sampleRoute = RouteModel(
    points: <GeoPoint>[
      GeoPoint(latitude: 30.0190, longitude: 31.2140),
      GeoPoint(latitude: 30.0210, longitude: 31.2160),
      GeoPoint(latitude: 30.0250, longitude: 31.2200),
    ],
    distanceMeters: 1400.0,
    durationSeconds: 200.0,
    encodedPolyline: 'sample_encoded',
  );

  UserLocationEntity createLocationEntity({
    double latitude = 30.0444,
    double longitude = 31.2357,
  }) {
    return UserLocationEntity(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.utc(2026, 11, 3),
    );
  }

  setUpAll(() {
    registerFallbackValue(const GeoPoint(latitude: 0, longitude: 0));
  });

  setUp(() {
    mockLocationStreamUseCase = MockGetDriverLocationStreamUseCase();
    mockCheckPermissionUseCase = MockCheckLocationPermissionUseCase();
    mockGetCurrentLocationUseCase = MockGetCurrentDriverLocationUseCase();
    mockGetRouteUseCase = MockGetRouteUseCase();
    mockUrlLauncherService = MockUrlLauncherService();
    locationStreamController =
        StreamController<BaseResponse<UserLocationEntity>>.broadcast();

    when(() => mockLocationStreamUseCase.call())
        .thenAnswer((_) => locationStreamController.stream);
    when(() => mockCheckPermissionUseCase.call()).thenAnswer((_) async => true);
    when(() => mockGetCurrentLocationUseCase.call())
        .thenAnswer((_) async => Success(createLocationEntity()));
    when(
      () => mockGetRouteUseCase.call(
        origin: any(named: 'origin'),
        destination: any(named: 'destination'),
      ),
    ).thenAnswer((_) async => const Success(sampleRoute));

    cubit = DeliveryMapCubit(
      getDriverLocationStreamUseCase: mockLocationStreamUseCase,
      checkLocationPermissionUseCase: mockCheckPermissionUseCase,
      getCurrentDriverLocationUseCase: mockGetCurrentLocationUseCase,
      getRouteUseCase: mockGetRouteUseCase,
      urlLauncherService: mockUrlLauncherService,
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
      'InitDeliveryMapEvent initializes addresses, starts tracking, fetches route, and emits FitBounds',
      build: () => cubit,
      act: (c) => c.doEvent(
        const InitDeliveryMapEvent(
          pickupAddress: samplePickup,
          userAddress: sampleUser,
          initialTarget: DeliveryMapTarget.user,
        ),
      ),
      verify: (c) {
        expect(c.state.pickupAddress, samplePickup);
        expect(c.state.userAddress, sampleUser);
        expect(c.state.target, DeliveryMapTarget.user);
        expect(c.state.hasLocationPermission, isTrue);
        expect(c.state.isTrackingLocation, isTrue);
        expect(
          c.state.driverPosition,
          const GeoPoint(latitude: 30.0444, longitude: 31.2357),
        );
        expect(c.state.route, sampleRoute);
        expect(c.state.routeFailure, isNull);
        verify(
          () => mockGetRouteUseCase.call(
            origin: any(named: 'origin'),
            destination: any(named: 'destination'),
          ),
        ).called(1);
      },
    );

    test('InitDeliveryMapEvent emits DeliveryMapFitBounds UI event', () async {
      final events = <BaseUiEvent>[];
      final sub = cubit.uiEventStream.listen(events.add);

      await cubit.doEvent(
        const InitDeliveryMapEvent(
          pickupAddress: samplePickup,
          userAddress: sampleUser,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(events, contains(isA<DeliveryMapFitBounds>()));
      await sub.cancel();
    });

    blocTest<DeliveryMapCubit, DeliveryMapState>(
      'SwitchTargetEvent updates active target and fetches new route',
      build: () => cubit,
      act: (c) async {
        await c.doEvent(
          const InitDeliveryMapEvent(
            pickupAddress: samplePickup,
            userAddress: sampleUser,
            initialTarget: DeliveryMapTarget.pickup,
          ),
        );
        await c.doEvent(const SwitchTargetEvent(DeliveryMapTarget.user));
        // Calling same target again should be a no-op
        await c.doEvent(const SwitchTargetEvent(DeliveryMapTarget.user));
      },
      verify: (c) {
        expect(c.state.target, DeliveryMapTarget.user);
        expect(c.state.route, sampleRoute);
        verify(
          () => mockGetRouteUseCase.call(
            origin: any(named: 'origin'),
            destination: any(named: 'destination'),
          ),
        ).called(2);
      },
    );

    test('StartDriverLocationTrackingEvent handles permission denied', () async {
      when(() => mockCheckPermissionUseCase.call())
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

    test('location stream Error responses emit appropriate UI events', () async {
      final events = <BaseUiEvent>[];
      final sub = cubit.uiEventStream.listen(events.add);

      await cubit.doEvent(const StartDriverLocationTrackingEvent());

      locationStreamController.add(
        const Error<UserLocationEntity>(LocationServiceDisabledFailure()),
      );
      locationStreamController.add(
        const Error<UserLocationEntity>(LocationPermissionFailure()),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(events, contains(isA<DeliveryMapLocationServiceDisabled>()));
      expect(events, contains(isA<DeliveryMapLocationPermissionDenied>()));

      await sub.cancel();
    });

    test('location stream Success updates driverPosition and fetches route on major movement', () async {
      await cubit.doEvent(
        const InitDeliveryMapEvent(
          pickupAddress: samplePickup,
          userAddress: sampleUser,
        ),
      );

      locationStreamController.add(
        Success(createLocationEntity(latitude: 30.5555, longitude: 31.6666)),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(
        cubit.state.driverPosition,
        const GeoPoint(latitude: 30.5555, longitude: 31.6666),
      );
      expect(cubit.state.route, sampleRoute);
    });

    test('DriverPositionUpdatedEvent debounces route fetch on minor movement (< 40m)', () async {
      await cubit.doEvent(
        const InitDeliveryMapEvent(
          pickupAddress: samplePickup,
          userAddress: sampleUser,
        ),
      );

      clearInteractions(mockGetRouteUseCase);

      // Micro movement (~1.5 meters from 30.0444, 31.2357)
      await cubit.doEvent(
        const DriverPositionUpdatedEvent(
          GeoPoint(latitude: 30.04441, longitude: 31.23571),
        ),
      );

      expect(
        cubit.state.driverPosition,
        const GeoPoint(latitude: 30.04441, longitude: 31.23571),
      );
      verifyNever(
        () => mockGetRouteUseCase.call(
          origin: any(named: 'origin'),
          destination: any(named: 'destination'),
        ),
      );
    });

    test('route fetch failure stores routeFailure in state and clears previous route', () async {
      await cubit.doEvent(
        const InitDeliveryMapEvent(
          pickupAddress: samplePickup,
          userAddress: sampleUser,
        ),
      );

      when(
        () => mockGetRouteUseCase.call(
          origin: any(named: 'origin'),
          destination: any(named: 'destination'),
        ),
      ).thenAnswer((_) async => const Error(InternetConnectionFailure()));

      await cubit.doEvent(const SwitchTargetEvent(DeliveryMapTarget.user));

      expect(cubit.state.isRouteLoading, isFalse);
      expect(cubit.state.route, isNull);
      expect(cubit.state.routeFailure, isA<InternetConnectionFailure>());
      expect(cubit.state.hasRouteFailure, isTrue);
    });

    test('StopDriverLocationTrackingEvent cancels tracking', () async {
      await cubit.doEvent(const StartDriverLocationTrackingEvent());
      expect(cubit.state.isTrackingLocation, isTrue);

      await cubit.doEvent(const StopDriverLocationTrackingEvent());
      expect(cubit.state.isTrackingLocation, isFalse);
    });

    test('CallPhoneEvent and OpenWhatsAppEvent delegate to UrlLauncherService and emit failure UI event when false', () async {
      when(() => mockUrlLauncherService.callPhone('+201000000000'))
          .thenAnswer((_) async => true);
      when(() => mockUrlLauncherService.openWhatsApp('+201000000000'))
          .thenAnswer((_) async => false);

      final events = <BaseUiEvent>[];
      final sub = cubit.uiEventStream.listen(events.add);

      await cubit.doEvent(const CallPhoneEvent(null));
      await cubit.doEvent(const CallPhoneEvent('   '));
      await cubit.doEvent(const CallPhoneEvent('+201000000000'));
      await cubit.doEvent(const OpenWhatsAppEvent('+201000000000'));
      await Future<void>.delayed(Duration.zero);

      verify(() => mockUrlLauncherService.callPhone('+201000000000')).called(1);
      verify(() => mockUrlLauncherService.openWhatsApp('+201000000000'))
          .called(1);
      expect(events.whereType<DeliveryMapLaunchUrlFailed>().length, 1);

      await sub.cancel();
    });
  });
}
