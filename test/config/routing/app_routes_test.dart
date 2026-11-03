import 'dart:async';

import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/config/routing/app_routes.dart';
import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/core/constants/api_strings/api_strings.dart';
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

void main() {
  late MockGetDriverOrderDetailsUseCase getOrderDetails;
  late MockUpdateOrderStatusUseCase updateOrderStatus;
  late MockReportDriverLocationUseCase reportDriverLocation;

  setUp(() {
    getOrderDetails = MockGetDriverOrderDetailsUseCase();
    updateOrderStatus = MockUpdateOrderStatusUseCase();
    reportDriverLocation = MockReportDriverLocationUseCase();

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

    if (getIt.isRegistered<OrderDetailsCubit>()) {
      getIt.unregister<OrderDetailsCubit>();
    }

    getIt.registerFactory<OrderDetailsCubit>(
      () => OrderDetailsCubit(
        getDriverOrderDetailsUseCase: getOrderDetails,
        updateOrderStatusUseCase: updateOrderStatus,
        reportDriverLocationUseCase: reportDriverLocation,
      ),
    );
  });

  tearDown(() {
    if (getIt.isRegistered<OrderDetailsCubit>()) {
      getIt.unregister<OrderDetailsCubit>();
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
      final viewWidget = tester.widget<OrderDetailsView>(orderDetailsViewFinder);
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
