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

void main() {
  late MockGetDriverOrderDetailsUseCase getOrderDetails;
  late MockUpdateOrderStatusUseCase updateOrderStatus;
  late MockContactLauncher contactLauncher;
  late MockGetDrivingRouteUseCase getDrivingRoute;
  late OrderDetailsCubit orderDetailsCubit;
  late PickupLocationCubit pickupLocationCubit;

  setUpAll(() => registerFallbackValue(kDrivingRouteParams));

  setUp(() {
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
  });

  Future<void> pumpView(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(375, 812);
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

  testWidgets(
    'falls back to the placeholder coordinates without order details',
    (tester) async {
      await pumpView(tester);

      final params =
          verify(() => getDrivingRoute.execute(captureAny())).captured.single
              as DrivingRouteParams;

      expect(
        params.origin.latitude,
        PickupLocationView.fallbackPickupLocation.latitude,
      );
      expect(
        params.origin.longitude,
        PickupLocationView.fallbackPickupLocation.longitude,
      );
      expect(
        params.destination.latitude,
        PickupLocationView.fallbackCustomerLocation.latitude,
      );
      expect(
        params.destination.longitude,
        PickupLocationView.fallbackCustomerLocation.longitude,
      );
    },
  );
}
