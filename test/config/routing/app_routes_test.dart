import 'dart:async';

import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/config/routing/app_routes.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/core/constants/api_strings/api_strings.dart';
import 'package:driver_app/core/services/url_launcher/url_launcher_service.dart';
import 'package:driver_app/features/delivery_map/domain/models/address_model.dart';
import 'package:driver_app/features/delivery_map/domain/models/delivery_map_args.dart';
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
import 'package:driver_app/features/order_details/domain/usecases/get_driver_order_details_use_case.dart';
import 'package:driver_app/features/order_details/domain/usecases/report_driver_location_use_case.dart';
import 'package:driver_app/features/order_details/domain/usecases/update_order_status_use_case.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_cubit.dart';
import 'package:driver_app/features/order_details/presentation/view/order_details_view.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/widget_harness.dart';

class MockGetDriverOrderDetailsUseCase extends Mock
    implements GetDriverOrderDetailsUseCase {}

class MockUpdateOrderStatusUseCase extends Mock
    implements UpdateOrderStatusUseCase {}

class MockReportDriverLocationUseCase extends Mock
    implements ReportDriverLocationUseCase {}

class MockStreamSubscription extends Mock
    implements StreamSubscription<BaseResponse<UserLocationEntity>> {}

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

  late MockGetDriverOrderDetailsUseCase getOrderDetails;
  late MockUpdateOrderStatusUseCase updateOrderStatus;
  late MockReportDriverLocationUseCase reportDriverLocation;
  late MockGetDriverLocationStreamUseCase getDriverLocationStream;
  late MockCheckLocationPermissionUseCase checkLocationPermission;
  late MockGetCurrentDriverLocationUseCase getCurrentDriverLocation;
  late MockGetRouteUseCase getRoute;
  late MockUrlLauncherService urlLauncherService;

  setUp(() {
    getOrderDetails = MockGetDriverOrderDetailsUseCase();
    updateOrderStatus = MockUpdateOrderStatusUseCase();
    reportDriverLocation = MockReportDriverLocationUseCase();
    getDriverLocationStream = MockGetDriverLocationStreamUseCase();
    checkLocationPermission = MockCheckLocationPermissionUseCase();
    getCurrentDriverLocation = MockGetCurrentDriverLocationUseCase();
    getRoute = MockGetRouteUseCase();
    urlLauncherService = MockUrlLauncherService();

    when(
      () => reportDriverLocation.start(
        onReportResult: any(named: 'onReportResult'),
        minDisplacementMeters: any(named: 'minDisplacementMeters'),
      ),
    ).thenAnswer((_) {
      final sub = MockStreamSubscription();
      when(() => sub.cancel()).thenAnswer((_) async {});
      return sub;
    });

    when(() => getOrderDetails.execute(any())).thenAnswer(
      (_) async => Success(buildDriverOrderDetailsEntity()),
    );

    when(() => getDriverLocationStream.call()).thenAnswer(
      (_) => const Stream<BaseResponse<UserLocationEntity>>.empty(),
    );
    when(() => checkLocationPermission.call()).thenAnswer((_) async => true);
    when(() => getCurrentDriverLocation.call())
        .thenAnswer((_) async => const Success(null));
    when(
      () => getRoute.call(
        origin: any(named: 'origin'),
        destination: any(named: 'destination'),
      ),
    ).thenAnswer(
      (_) async => const Success(
        RouteModel(
          points: <GeoPoint>[GeoPoint(latitude: 30, longitude: 31)],
          distanceMeters: 100,
          durationSeconds: 30,
        ),
      ),
    );

    if (getIt.isRegistered<OrderDetailsCubit>()) {
      getIt.unregister<OrderDetailsCubit>();
    }
    if (getIt.isRegistered<DeliveryMapCubit>()) {
      getIt.unregister<DeliveryMapCubit>();
    }

    getIt.registerFactory<OrderDetailsCubit>(
      () => OrderDetailsCubit(
        getDriverOrderDetailsUseCase: getOrderDetails,
        updateOrderStatusUseCase: updateOrderStatus,
        reportDriverLocationUseCase: reportDriverLocation,
      ),
    );

    getIt.registerFactory<DeliveryMapCubit>(
      () => DeliveryMapCubit(
        getDriverLocationStreamUseCase: getDriverLocationStream,
        checkLocationPermissionUseCase: checkLocationPermission,
        getCurrentDriverLocationUseCase: getCurrentDriverLocation,
        getRouteUseCase: getRoute,
        urlLauncherService: urlLauncherService,
      ),
    );
  });

  tearDown(() {
    if (getIt.isRegistered<OrderDetailsCubit>()) {
      getIt.unregister<OrderDetailsCubit>();
    }
    if (getIt.isRegistered<DeliveryMapCubit>()) {
      getIt.unregister<DeliveryMapCubit>();
    }
  });

  Widget buildApp(Widget pageChild) {
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
        home: pageChild,
      ),
    );
  }

  group('AppRoutes.onGenerateRoute for orderDetails', () {
    testWidgets('resolves orderId from valid String argument', (tester) async {
      useDesignSurface(tester);
      const customOrderId = 'custom-order-123';
      final route = AppRoutes.onGenerateRoute(
        const RouteSettings(
          name: Routes.orderDetails,
          arguments: customOrderId,
        ),
      );

      expect(route, isA<MaterialPageRoute>());

      final page = route as MaterialPageRoute;
      await tester.pumpWidget(
        buildApp(Builder(builder: (ctx) => page.buildContent(ctx))),
      );
      await tester.pumpAndSettle();

      final orderDetailsViewFinder = find.byType(OrderDetailsView);
      expect(orderDetailsViewFinder, findsOneWidget);
      final viewWidget =
          tester.widget<OrderDetailsView>(orderDetailsViewFinder);
      expect(viewWidget.orderId, equals(customOrderId));
    });

    testWidgets('resolves orderId from Map with orderId key', (tester) async {
      useDesignSurface(tester);
      const mapOrderId = 'map-order-456';
      final route = AppRoutes.onGenerateRoute(
        const RouteSettings(
          name: Routes.orderDetails,
          arguments: {'orderId': mapOrderId},
        ),
      );

      final page = route as MaterialPageRoute;
      await tester.pumpWidget(
        buildApp(Builder(builder: (ctx) => page.buildContent(ctx))),
      );
      await tester.pumpAndSettle();

      final viewWidget = tester.widget<OrderDetailsView>(
        find.byType(OrderDetailsView),
      );
      expect(viewWidget.orderId, equals(mapOrderId));
    });

    testWidgets('resolves orderId from Map with id key', (tester) async {
      useDesignSurface(tester);
      const mapId = 'map-id-789';
      final route = AppRoutes.onGenerateRoute(
        const RouteSettings(
          name: Routes.orderDetails,
          arguments: {'id': mapId},
        ),
      );

      final page = route as MaterialPageRoute;
      await tester.pumpWidget(
        buildApp(Builder(builder: (ctx) => page.buildContent(ctx))),
      );
      await tester.pumpAndSettle();

      final viewWidget = tester.widget<OrderDetailsView>(
        find.byType(OrderDetailsView),
      );
      expect(viewWidget.orderId, equals(mapId));
    });

    testWidgets('falls back to ApiStrings.defaultOrderId when arguments is null (initialRoute)', (tester) async {
      useDesignSurface(tester);
      final route = AppRoutes.onGenerateRoute(
        const RouteSettings(
          name: Routes.orderDetails,
          arguments: null,
        ),
      );

      final page = route as MaterialPageRoute;
      await tester.pumpWidget(
        buildApp(Builder(builder: (ctx) => page.buildContent(ctx))),
      );
      await tester.pumpAndSettle();

      final viewWidget = tester.widget<OrderDetailsView>(
        find.byType(OrderDetailsView),
      );
      expect(viewWidget.orderId, equals(ApiStrings.defaultOrderId));
    });

    testWidgets('shows Material 3 error screen when orderId is empty string', (tester) async {
      final route = AppRoutes.onGenerateRoute(
        const RouteSettings(
          name: Routes.orderDetails,
          arguments: '   ',
        ),
      );

      final page = route as MaterialPageRoute;
      await tester.pumpWidget(
        buildApp(Builder(builder: (ctx) => page.buildContent(ctx))),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OrderDetailsView), findsNothing);
      expect(find.text('Invalid order ID'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('handles pickupLocation and tracking routes with DeliveryMapArgs and missing args', (tester) async {
      useDesignSurface(tester);

      const args = DeliveryMapArgs(
        pickupAddress: AddressModel(
          title: 'Flowery Store',
          addressLine: 'Giza',
          latitude: 30.01,
          longitude: 31.20,
        ),
        userAddress: AddressModel(
          title: 'Customer',
          addressLine: 'Cairo',
          latitude: 30.05,
          longitude: 31.24,
        ),
      );

      final validRoute = AppRoutes.onGenerateRoute(
        const RouteSettings(
          name: Routes.pickupLocation,
          arguments: args,
        ),
      ) as MaterialPageRoute;

      await tester.pumpWidget(
        buildApp(Builder(builder: (ctx) => validRoute.buildContent(ctx))),
      );
      await tester.pump();

      final view = tester.widget<DeliveryMapView>(find.byType(DeliveryMapView));
      expect(view.pickupAddress, args.pickupAddress);
      expect(view.userAddress, args.userAddress);
      expect(view.initialTarget, DeliveryMapTarget.pickup);

      // Invalid/missing arguments -> shows missing context screen
      final invalidRoute = AppRoutes.onGenerateRoute(
        const RouteSettings(
          name: Routes.tracking,
          arguments: 'invalid',
        ),
      ) as MaterialPageRoute;

      await tester.pumpWidget(
        buildApp(Builder(builder: (ctx) => invalidRoute.buildContent(ctx))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Order details context is missing'), findsWidgets);
    });

    testWidgets('handles default unknown route', (tester) async {
      final route = AppRoutes.onGenerateRoute(
        const RouteSettings(
          name: '/unknown-route',
        ),
      );

      final page = route as MaterialPageRoute;
      await tester.pumpWidget(
        buildApp(Builder(builder: (ctx) => page.buildContent(ctx))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Not Found'), findsWidgets);
    });
  });
}
