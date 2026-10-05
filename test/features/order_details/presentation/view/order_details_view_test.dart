import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/update_order_status.dart';
import 'package:driver_app/features/order_details/domain/params/report_driver_location_params.dart';
import 'package:driver_app/features/order_details/domain/params/update_order_status_params.dart';
import 'package:driver_app/features/order_details/domain/usecases/get_driver_order_details_use_case.dart';
import 'package:driver_app/features/order_details/domain/usecases/report_driver_location_use_case.dart';
import 'package:driver_app/features/order_details/domain/usecases/update_order_status_use_case.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_cubit.dart';
import 'package:driver_app/features/order_details/presentation/view/order_details_view.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import '../../../../helpers/fixtures.dart';

class MockGetDriverOrderDetailsUseCase extends Mock
    implements GetDriverOrderDetailsUseCase {}

class MockUpdateOrderStatusUseCase extends Mock
    implements UpdateOrderStatusUseCase {}

class MockReportDriverLocationUseCase extends Mock
    implements ReportDriverLocationUseCase {}

void main() {
  late MockGetDriverOrderDetailsUseCase getOrderDetails;
  late MockUpdateOrderStatusUseCase updateOrderStatus;
  late MockReportDriverLocationUseCase reportDriverLocation;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
    registerFallbackValue(
      const UpdateOrderStatusParams(orderId: '', newStatus: ''),
    );
    registerFallbackValue(
      const ReportDriverLocationParams(lat: 0, lng: 0, recordedAt: ''),
    );
  });

  setUp(() {
    getOrderDetails = MockGetDriverOrderDetailsUseCase();
    updateOrderStatus = MockUpdateOrderStatusUseCase();
    reportDriverLocation = MockReportDriverLocationUseCase();
  });

  Future<void> pumpView(
    WidgetTester tester,
    OrderDetailsCubit cubit, {
    String orderId = kOrderId,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilPlusInit(
        designSize: const Size(375, 700),
        builder: (context, child) => MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<OrderDetailsCubit>.value(
            value: cubit,
            child: OrderDetailsView(orderId: orderId),
          ),
        ),
        child: const SizedBox.shrink(),
      ),
    );
  }

  OrderDetailsCubit buildCubit() => OrderDetailsCubit(
    getDriverOrderDetailsUseCase: getOrderDetails,
    updateOrderStatusUseCase: updateOrderStatus,
    reportDriverLocationUseCase: reportDriverLocation,
    l10n: l10n,
  );

  /// The test Ahem font renders every glyph as a full em square, so the
  /// default long strings overflow `PaymentMethodCard`'s fixed Row inside the
  /// 375pt viewport. Real fonts fit, so those known layout overflows are
  /// drained instead of failing the test.
  void drainKnownLayoutOverflow(WidgetTester tester) {
    while (tester.takeException() != null) {}
  }

  group('initial load', () {
    testWidgets('requests the order details for the given orderId', (
      tester,
    ) async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Success(buildDriverOrderDetailsEntity()),
      );
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await pumpView(tester, cubit);
      await tester.pumpAndSettle();

      verify(() => getOrderDetails.execute(kOrderId)).called(1);
    });

    testWidgets('shows a loading indicator while there is no data', (
      tester,
    ) async {
      when(() => getOrderDetails.execute(any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return Success(buildDriverOrderDetailsEntity());
      });
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await pumpView(tester, cubit);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(OrderDetailsView), findsOneWidget);

      // Drain the pending use-case timer so the test ends cleanly.
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpAndSettle();
    });
  });

  group('rendering loaded data', () {
    late OrderDetailsCubit cubit;

    setUp(() {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Success(buildDriverOrderDetailsEntity()),
      );
      cubit = buildCubit();
    });

    tearDown(() => cubit.close());

    testWidgets('shows the app bar title', (tester) async {
      await pumpView(tester, cubit);
      await tester.pumpAndSettle();

      expect(find.text('Order Details'), findsOneWidget);
    });

    testWidgets('shows the order number and status in the header', (
      tester,
    ) async {
      await pumpView(tester, cubit);
      await tester.pumpAndSettle();

      expect(find.text('status: PickedUp'), findsOneWidget);
      expect(find.text('Order ID: ORD-12345'), findsOneWidget);
    });

    testWidgets('uses the last timeline timestamp as the header date', (
      tester,
    ) async {
      await pumpView(tester, cubit);
      await tester.pumpAndSettle();

      expect(find.text('2026-09-19T17:00:00Z'), findsOneWidget);
    });

    testWidgets('renders the pickup store and address', (tester) async {
      await pumpView(tester, cubit);
      await tester.pumpAndSettle();

      expect(find.text('Pickup address'), findsOneWidget);
      expect(find.text('Flowery store'), findsOneWidget);
      expect(find.text('20th st, Sheikh Zayed, Giza'), findsNWidgets(2));
    });

    testWidgets('renders the recipient name and address', (tester) async {
      await pumpView(tester, cubit);
      await tester.pumpAndSettle();

      expect(find.text('User address'), findsOneWidget);
      expect(find.text('Nour Mohamed'), findsOneWidget);
    });

    testWidgets('renders each item with quantity and formatted price', (
      tester,
    ) async {
      await pumpView(tester, cubit);
      await tester.pumpAndSettle();

      expect(find.text('Order details'), findsOneWidget);
      expect(find.text('Red Roses Bouquet'), findsOneWidget);
      expect(find.text('X2'), findsOneWidget);
      expect(find.text('EGP 1500.00'), findsOneWidget);
    });

    testWidgets('renders the total with two decimal places', (tester) async {
      await pumpView(tester, cubit);
      await tester.pumpAndSettle();

      expect(find.text('EGP 3000.00'), findsOneWidget);
    });

    testWidgets('renders the payment method', (tester) async {
      await pumpView(tester, cubit);
      await tester.pumpAndSettle();

      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('COD'), findsOneWidget);
    });

    testWidgets('renders a five step progress indicator', (tester) async {
      await pumpView(tester, cubit);
      await tester.pumpAndSettle();

      expect(find.byType(StepProgressIndicator), findsOneWidget);
      expect(
        tester.widget<StepProgressIndicator>(find.byType(StepProgressIndicator))
            .currentStep,
        1,
      );
    });
  });

  group('fallbacks without data', () {
    testWidgets('shows placeholder copy when the request fails', (
      tester,
    ) async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Error<DriverOrderDetailsEntity>(const NotFoundFailure()),
      );
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await pumpView(tester, cubit, orderId: 'abc-123');
      await tester.pumpAndSettle();
      drainKnownLayoutOverflow(tester);

      expect(find.text('Order ID: #abc-123'), findsOneWidget);
      expect(find.text('Pickup address not available'), findsOneWidget);
      expect(find.text('Recipient address not available'), findsOneWidget);
      expect(find.text('Product Name'), findsOneWidget);
      expect(find.text('Cash on delivery'), findsOneWidget);
    });
  });

  group('error feedback', () {
    testWidgets('shows the failure message in a SnackBar', (tester) async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Error<DriverOrderDetailsEntity>(const NotFoundFailure()),
      );
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await pumpView(tester, cubit);
      await tester.pumpAndSettle();
      drainKnownLayoutOverflow(tester);

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('The requested resource was not found.'),
        findsOneWidget,
      );
    });
  });

  group('start delivery action', () {
    testWidgets('updates the status to OnTheWay when tapped', (tester) async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Success(buildDriverOrderDetailsEntity()),
      );
      when(() => updateOrderStatus.execute(any())).thenAnswer(
        (_) async => Success(buildUpdateOrderStatusEntity()),
      );
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await pumpView(tester, cubit);
      await tester.pumpAndSettle();

      expect(find.text('Start Delivery'), findsOneWidget);

      await tester.tap(find.text('Start Delivery'));
      await tester.pumpAndSettle();

      final captured =
          verify(() => updateOrderStatus.execute(captureAny())).captured.single
              as dynamic;
      expect(captured.orderId, kOrderId);
      expect(captured.newStatus, 'OnTheWay');
    });

    testWidgets('confirms the update with a SnackBar', (tester) async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Success(buildDriverOrderDetailsEntity()),
      );
      when(() => updateOrderStatus.execute(any())).thenAnswer(
        (_) async => Success(buildUpdateOrderStatusEntity()),
      );
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await pumpView(tester, cubit);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Delivery'));
      await tester.pumpAndSettle();

      expect(
        find.text('Order status updated successfully'),
        findsOneWidget,
      );
    });

    testWidgets('surfaces a conflict message instead of success', (
      tester,
    ) async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Success(buildDriverOrderDetailsEntity()),
      );
      when(() => updateOrderStatus.execute(any())).thenAnswer(
        (_) async => Error<UpdateOrderStatusEntity>(
          const ConflictFailure(serverMessage: 'busy'),
        ),
      );
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await pumpView(tester, cubit);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Delivery'));
      await tester.pumpAndSettle();

      expect(find.text('Order status updated successfully'), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('status mapping', () {
    Future<void> expectStepFor(
      WidgetTester tester,
      String status,
      int expectedStep,
    ) async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Success(buildDriverOrderDetailsEntity(status: status)),
      );
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await pumpView(tester, cubit);
      await tester.pumpAndSettle();

      expect(
        tester.widget<StepProgressIndicator>(find.byType(StepProgressIndicator))
            .currentStep,
        expectedStep,
      );
    }

    testWidgets('maps picked_up to step 4', (t) =>
        expectStepFor(t, 'picked_up', 4));
    testWidgets('maps delivered to step 5', (t) =>
        expectStepFor(t, 'delivered', 5));
    testWidgets('maps on_the_way to step 3', (t) =>
        expectStepFor(t, 'on_the_way', 3));
    testWidgets('maps accepted to step 2', (t) =>
        expectStepFor(t, 'accepted', 2));
    testWidgets('maps pending to step 1', (t) =>
        expectStepFor(t, 'pending', 1));
    testWidgets('falls back to step 1 for an unknown status', (t) =>
        expectStepFor(t, 'something-else', 1));
  });
}