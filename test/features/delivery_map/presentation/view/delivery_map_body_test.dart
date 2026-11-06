import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
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
import 'package:driver_app/features/delivery_map/presentation/view/delivery_map_body.dart';
import 'package:driver_app/features/delivery_map/presentation/widgets/delivery_bottom_sheet.dart';
import 'package:driver_app/features/delivery_map/presentation/widgets/delivery_map_back_button.dart';
import 'package:driver_app/features/order_details/domain/entities/user_location_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/widget_harness.dart';

class MockGetDriverLocationStreamUseCase extends Mock
    implements GetDriverLocationStreamUseCase {}

class MockCheckLocationPermissionUseCase extends Mock
    implements CheckLocationPermissionUseCase {}

class MockGetCurrentDriverLocationUseCase extends Mock
    implements GetCurrentDriverLocationUseCase {}

class MockGetRouteUseCase extends Mock implements GetRouteUseCase {}

class MockUrlLauncherService extends Mock implements UrlLauncherService {}

class MockGoogleMapController extends Mock implements GoogleMapController {}

void main() {
  setUpAll(() {
    registerFallbackValue(const GeoPoint(latitude: 0, longitude: 0));
    registerFallbackValue(CameraUpdate.zoomIn());
  });

  late MockGetDriverLocationStreamUseCase mockLocationStreamUseCase;
  late MockCheckLocationPermissionUseCase mockCheckPermissionUseCase;
  late MockGetCurrentDriverLocationUseCase mockGetCurrentLocationUseCase;
  late MockGetRouteUseCase mockGetRouteUseCase;
  late MockUrlLauncherService mockUrlLauncherService;
  late DeliveryMapCubit cubit;

  const samplePickup = AddressModel(
    title: 'Flowery store',
    addressLine: '20th st, Sheikh Zayed, Giza',
    latitude: 30.0131,
    longitude: 31.2089,
    phoneNumber: '+201000000000',
  );

  const sampleUser = AddressModel(
    title: 'Nour mohamed',
    addressLine: '20th st, Sheikh Zayed, Giza',
    latitude: 30.0250,
    longitude: 31.2200,
    phoneNumber: '+201011111111',
  );

  const sampleRoute = RouteModel(
    points: <GeoPoint>[
      GeoPoint(latitude: 30.0190, longitude: 31.2140),
      GeoPoint(latitude: 30.0250, longitude: 31.2200),
    ],
    distanceMeters: 1500.0,
    durationSeconds: 300.0,
  );

  setUp(() {
    mockLocationStreamUseCase = MockGetDriverLocationStreamUseCase();
    mockCheckPermissionUseCase = MockCheckLocationPermissionUseCase();
    mockGetCurrentLocationUseCase = MockGetCurrentDriverLocationUseCase();
    mockGetRouteUseCase = MockGetRouteUseCase();
    mockUrlLauncherService = MockUrlLauncherService();

    when(() => mockLocationStreamUseCase.call()).thenAnswer(
      (_) => const Stream<BaseResponse<UserLocationEntity>>.empty(),
    );
    when(() => mockCheckPermissionUseCase.call()).thenAnswer((_) async => true);
    when(() => mockGetCurrentLocationUseCase.call()).thenAnswer(
      (_) async => Success(
        UserLocationEntity(
          latitude: 30.0190,
          longitude: 31.2140,
          timestamp: DateTime.utc(2026, 11, 3),
        ),
      ),
    );
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
    await cubit.close();
  });

  group('DeliveryMapBody', () {
    testWidgets('renders GoogleMap, DeliveryMapBackButton, and DeliveryBottomSheet with markers and polylines', (tester) async {
      useDesignSurface(tester);

      await cubit.doEvent(
        const InitDeliveryMapEvent(
          pickupAddress: samplePickup,
          userAddress: sampleUser,
          initialTarget: DeliveryMapTarget.pickup,
        ),
      );

      await tester.pumpWidget(
        wrapWidget(
          BlocProvider.value(
            value: cubit,
            child: const SizedBox(
              width: 375,
              height: 812,
              child: DeliveryMapBody(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(GoogleMap), findsOneWidget);
      expect(find.byType(DeliveryMapBackButton), findsOneWidget);
      expect(find.byType(DeliveryBottomSheet), findsOneWidget);

      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
      expect(googleMap.markers.length, 2);
      expect(googleMap.polylines.length, 1);

      final pickupMarker = googleMap.markers.firstWhere(
        (m) => m.markerId == const MarkerId('pickup_marker'),
      );
      expect(pickupMarker.infoWindow.title, 'Flowery store');
    });

    testWidgets('updates markers and handles DeliveryMapFitBounds UI event when target switches', (tester) async {
      useDesignSurface(tester);

      await cubit.doEvent(
        const InitDeliveryMapEvent(
          pickupAddress: samplePickup,
          userAddress: sampleUser,
          initialTarget: DeliveryMapTarget.pickup,
        ),
      );

      await tester.pumpWidget(
        wrapWidget(
          BlocProvider.value(
            value: cubit,
            child: const SizedBox(
              width: 375,
              height: 812,
              child: DeliveryMapBody(),
            ),
          ),
        ),
      );
      await tester.pump();

      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
      final mockController = MockGoogleMapController();
      when(() => mockController.animateCamera(any())).thenAnswer((_) async {});
      googleMap.onMapCreated?.call(mockController);
      await tester.pump();

      await cubit.doEvent(const SwitchTargetEvent(DeliveryMapTarget.user));
      cubit.emitEvent(const DeliveryMapFitBounds());
      await tester.pump();

      final updatedMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
      final userMarker = updatedMap.markers.firstWhere(
        (m) => m.markerId == const MarkerId('user_marker'),
      );
      expect(userMarker.infoWindow.title, 'Nour mohamed');

      await tester.tap(find.byType(DeliveryMapBackButton));
      await tester.pump();
    });
  });
}
