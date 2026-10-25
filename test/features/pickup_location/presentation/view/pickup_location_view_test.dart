import 'dart:async';

import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/features/order_details/domain/services/contact_launcher.dart';
import 'package:driver_app/features/order_details/domain/usecases/get_driver_order_details_use_case.dart';
import 'package:driver_app/features/order_details/domain/usecases/update_order_status_use_case.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_cubit.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_event.dart';
import 'package:driver_app/features/pickup_location/domain/params/driving_route_params.dart';
import 'package:driver_app/features/pickup_location/domain/usecases/get_driving_route_use_case.dart';
import 'package:driver_app/features/pickup_location/presentation/manager/cubit/pickup_location_cubit.dart';
import 'package:driver_app/features/pickup_location/presentation/view/pickup_location_view.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../pickup_location/fixtures.dart';

class MockGetDriverOrderDetailsUseCase extends Mock
    implements GetDriverOrderDetailsUseCase {}

class MockUpdateOrderStatusUseCase extends Mock
    implements UpdateOrderStatusUseCase {}

class MockContactLauncher extends Mock implements ContactLauncher {}

class MockGetDrivingRouteUseCase extends Mock
    implements GetDrivingRouteUseCase {}

class FakeGeolocatorPlatform extends GeolocatorPlatform {
  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async => Position(
    longitude: -122.08,
    latitude: 37.42,
    timestamp: DateTime.utc(2024),
    accuracy: 1,
    altitude: 0,
    altitudeAccuracy: 1,
    heading: 0,
    headingAccuracy: 1,
    speed: 0,
    speedAccuracy: 1,
  );
}

void main() {
  late MockGetDriverOrderDetailsUseCase getOrderDetails;
  late MockUpdateOrderStatusUseCase updateOrderStatus;
  late MockContactLauncher contactLauncher;
  late MockGetDrivingRouteUseCase getDrivingRoute;
  late OrderDetailsCubit orderDetailsCubit;
  late PickupLocationCubit pickupLocationCubit;
  late GeolocatorPlatform originalGeolocatorPlatform;

  setUpAll(() => registerFallbackValue(kDrivingRouteParams));

  setUp(() {
    originalGeolocatorPlatform = GeolocatorPlatform.instance;
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();

    getOrderDetails = MockGetDriverOrderDetailsUseCase();
    updateOrderStatus = MockUpdateOrderStatusUseCase();
    contactLauncher = MockContactLauncher();
    getDrivingRoute = MockGetDrivingRouteUseCase();

    when(
      () => contactLauncher.call(any()),
    ).thenAnswer((_) async => ContactLaunchOutcome.launched);
    when(
      () => contactLauncher.whatsApp(any()),
    ).thenAnswer((_) async => ContactLaunchOutcome.launched);

    when(
      () => getOrderDetails.execute(any()),
    ).thenAnswer((_) async => Success(buildDriverOrderDetailsEntity()));

    when(
      () => getDrivingRoute.execute(any()),
    ).thenAnswer((_) async => Success(buildDrivingRoute()));

    orderDetailsCubit = OrderDetailsCubit(
      getDriverOrderDetailsUseCase: getOrderDetails,
      updateOrderStatusUseCase: updateOrderStatus,
      contactLauncher: contactLauncher,
    );

    pickupLocationCubit = PickupLocationCubit(getDrivingRoute);

    getIt.registerFactory<PickupLocationCubit>(() => pickupLocationCubit);
  });

  tearDown(() async {
    await orderDetailsCubit.close();
    unawaited(pickupLocationCubit.close());
    await getIt.reset();
    GeolocatorPlatform.instance = originalGeolocatorPlatform;
  });

  Future<void> pumpView(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(450, 900);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilPlusInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<OrderDetailsCubit>.value(
            value: orderDetailsCubit,
            child: const PickupLocationView(),
          ),
        ),
        child: const SizedBox.shrink(),
      ),
    );

    await tester.pump();
    await tester.pump();
  }

  testWidgets('requests the route between the order coordinates', (
    tester,
  ) async {
    await orderDetailsCubit.doEvent(
      GetDriverOrderDetailsEvent(orderId: kOrderId),
    );

    await pumpView(tester);

    final params =
        verify(() => getDrivingRoute.execute(captureAny())).captured.single
            as DrivingRouteParams;

    expect(params.origin.latitude, 30.0511);
    expect(params.origin.longitude, 31.3656);
    expect(params.destination.latitude, 30.0444);
    expect(params.destination.longitude, 31.2357);
  });

  testWidgets('marks the pickup and the customer on the order coordinates', (
    tester,
  ) async {
    await orderDetailsCubit.doEvent(
      GetDriverOrderDetailsEvent(orderId: kOrderId),
    );

    await pumpView(tester);

    final map = tester.widget<GoogleMap>(find.byType(GoogleMap));

    final pickup = map.markers.firstWhere(
      (marker) => marker.markerId.value == 'pickup',
    );
    final customer = map.markers.firstWhere(
      (marker) => marker.markerId.value == 'user',
    );

    expect(pickup.position, const LatLng(30.0511, 31.3656));
    expect(customer.position, const LatLng(30.0444, 31.2357));
  });

  testWidgets('uses device location without order data or a route request', (
    tester,
  ) async {
    await pumpView(tester);
    await tester.pumpAndSettle();

    final map = tester.widget<GoogleMap>(find.byType(GoogleMap));

    expect(map.initialCameraPosition.target, const LatLng(37.42, -122.08));
    expect(map.markers, hasLength(1));
    expect(map.markers.single.markerId.value, 'driver');
    verifyNever(() => getDrivingRoute.execute(any()));
  });
}
