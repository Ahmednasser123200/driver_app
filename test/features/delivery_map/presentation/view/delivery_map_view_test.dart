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
import 'package:driver_app/features/delivery_map/presentation/view/delivery_map_view.dart';
import 'package:driver_app/features/order_details/domain/entities/user_location_entity.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
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

void main() {
  setUpAll(() {
    registerFallbackValue(const GeoPoint(latitude: 0, longitude: 0));
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
  );

  const sampleUser = AddressModel(
    title: 'Nour mohamed',
    addressLine: '20th st, Sheikh Zayed, Giza',
    latitude: 30.0250,
    longitude: 31.2200,
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
    when(() => mockGetCurrentLocationUseCase.call())
        .thenAnswer((_) async => const Success(null));
    when(
      () => mockGetRouteUseCase.call(
        origin: any(named: 'origin'),
        destination: any(named: 'destination'),
      ),
    ).thenAnswer(
      (_) async => const Success(
        RouteModel(
          points: <GeoPoint>[
            GeoPoint(latitude: 30.0131, longitude: 31.2089),
          ],
          distanceMeters: 500,
          durationSeconds: 60,
        ),
      ),
    );

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

  Widget buildTestApp() {
    return ScreenUtilPlusInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: BlocProvider.value(
          value: cubit,
          child: const DeliveryMapView(
            pickupAddress: samplePickup,
            userAddress: sampleUser,
            initialTarget: DeliveryMapTarget.pickup,
          ),
        ),
      ),
    );
  }

  group('DeliveryMapView', () {
    testWidgets('shows localized snackbars on UI events', (tester) async {
      useDesignSurface(tester);

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      cubit.emitEvent(const DeliveryMapLocationPermissionDenied());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.text('Location permission is required for live delivery tracking.'),
        findsOneWidget,
      );

      ScaffoldMessenger.of(
        tester.element(find.byType(DeliveryMapView)),
      ).clearSnackBars();
      await tester.pump();

      cubit.emitEvent(const DeliveryMapLocationServiceDisabled());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.text('Please enable GPS to track your delivery position.'),
        findsOneWidget,
      );

      ScaffoldMessenger.of(
        tester.element(find.byType(DeliveryMapView)),
      ).clearSnackBars();
      await tester.pump();

      cubit.emitEvent(const DeliveryMapLaunchUrlFailed('tel:123'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Could not open: tel:123'), findsOneWidget);
    });
  });
}
