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
  late OrderDetailsCubit cubit;

  setUpAll(() {
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
    cubit = OrderDetailsCubit(
      getDriverOrderDetailsUseCase: getOrderDetails,
      updateOrderStatusUseCase: updateOrderStatus,
      reportDriverLocationUseCase: reportDriverLocation,
    );
  });

  tearDown(() => cubit.close());

  Future<void> pumpView(
    WidgetTester tester, {
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

  void mockSuccess() {
    when(() => getOrderDetails.execute(any())).thenAnswer(
      (_) async => Success(buildDriverOrderDetailsEntity()),
    );
  }

  void mockFailure([AppFailure failure = const NotFoundFailure()]) {
    when(() => getOrderDetails.execute(any())).thenAnswer(
      (_) async => Error<DriverOrderDetailsEntity>(failure),
    );
  }

  group('initial load', () {
    testWidgets('requests the order details for the given orderId', (
      tester,
    ) async {
      mockSuccess();
      await pumpView(tester);
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

      await pumpView(tester);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Order details'), findsOneWidget);

      // Drain the pending use-case timer so the test ends cleanly.
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpAndSettle();
    });
  });

  group('rendering loaded data', () {
    setUp(mockSuccess);

    testWidgets('shows the localized app bar title', (tester) async {
      await pumpView(tester);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Order details'), findsOneWidget);
      // The section heading below reuses the same localized string.
      expect(find.text('Order details'), findsNWidgets(2));
    });

    testWidgets('shows the order number and status in the header', (
      tester,
    ) async {
      await pumpView(tester);
      await tester.pumpAndSettle();

      expect(find.text('status: PickedUp'), findsOneWidget);
      expect(find.text('Order ID: ORD-12345'), findsOneWidget);
    });

    testWidgets('uses the last timeline timestamp as the header date', (
      tester,
    ) async {
      await pumpView(tester);
      await tester.pumpAndSettle();

      expect(find.text('2026-09-19T17:00:00Z'), findsOneWidget);
    });

    testWidgets('renders the pickup store and address', (tester) async {
      await pumpView(tester);
      await tester.pumpAndSettle();

      expect(find.text('Pickup address'), findsOneWidget);
      expect(find.text('Flowery store'), findsOneWidget);
      expect(find.text('20th st, Sheikh Zayed, Giza'), findsNWidgets(2));
    });

    testWidgets('renders the recipient name and address', (tester) async {
      await pumpView(tester);
      await tester.pumpAndSettle();

      expect(find.text('User address'), findsOneWidget);
      expect(find.text('Nour Mohamed'), findsOneWidget);
    });

    testWidgets('renders each item with quantity and formatted price', (
      tester,
    ) async {
      await pumpView(tester);
      await tester.pumpAndSettle();

      expect(find.text('Order details'), findsNWidgets(2));
      expect(find.text('Red Roses Bouquet'), findsOneWidget);
      expect(find.text('X2'), findsOneWidget);
      expect(find.text('EGP 1500.00'), findsOneWidget);
    });

    testWidgets('renders the total with two decimal places', (tester) async {
      await pumpView(tester);
      await tester.pumpAndSettle();

      expect(find.text('EGP 3000.00'), findsOneWidget);
    });

    testWidgets('renders the payment method', (tester) async {
      await pumpView(tester);
      await tester.pumpAndSettle();

      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('COD'), findsOneWidget);
    });

    testWidgets('renders a five step progress indicator at step 1', (
      tester,
    ) async {
      await pumpView(tester);
      await tester.pumpAndSettle();

      expect(find.byType(StepProgressIndicator), findsOneWidget);
      expect(
        tester.widget<StepProgressIndicator>(find.byType(StepProgressIndicator))
            .currentStep,
        1,
      );
    });

    testWidgets('renders the localized start delivery action', (
      tester,
    ) async {
      await pumpView(tester);
      await tester.pumpAndSettle();

      expect(find.text('Start deliver'), findsOneWidget);
    });
  });

  group('failure state', () {
    testWidgets('shows the fallback error page instead of stale content', (
      tester,
    ) async {
      mockFailure();

      await pumpView(tester, orderId: 'abc-123');
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Order ID: #abc-123'), findsNothing);
    });

    testWidgets('shows the failure message in a SnackBar', (tester) async {
      mockFailure();

      await pumpView(tester);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('The requested resource was not found.'),
        findsOneWidget,
      );
    });

    testWidgets('retries when the continue action is tapped', (tester) async {
      mockFailure();
      await pumpView(tester);
      await tester.pumpAndSettle();

      reset(getOrderDetails);
      mockSuccess();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      verify(() => getOrderDetails.execute(kOrderId)).called(1);
      expect(find.text('Order ID: ORD-12345'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });
  });

  group('start delivery action', () {
    setUp(() {
      mockSuccess();
      when(() => updateOrderStatus.execute(any())).thenAnswer(
        (_) async => Success(buildUpdateOrderStatusEntity()),
      );
    });

    testWidgets('updates the status to OnTheWay when tapped', (tester) async {
      await pumpView(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start deliver'));
      await tester.pumpAndSettle();

      final captured =
          verify(() => updateOrderStatus.execute(captureAny())).captured.single
              as UpdateOrderStatusParams;
      expect(captured.orderId, kOrderId);
      expect(captured.newStatus, 'OnTheWay');
    });

    testWidgets('shows a loading spinner on the button while updating', (
      tester,
    ) async {
      when(() => updateOrderStatus.execute(any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return Success(buildUpdateOrderStatusEntity());
      });

      await pumpView(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start deliver'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Start deliver'), findsNothing);

      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpAndSettle();

      expect(find.text('Start deliver'), findsOneWidget);
    });

    testWidgets('shows the failure message when the update is rejected', (
      tester,
    ) async {
      when(() => updateOrderStatus.execute(any())).thenAnswer(
        (_) async => Error<UpdateOrderStatusEntity>(
          const ConflictFailure(serverMessage: 'busy'),
        ),
      );

      await pumpView(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start deliver'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('busy'), findsOneWidget);
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

      await pumpView(tester);
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

  group('localized status label', () {
    Future<void> expectLabel(
      WidgetTester tester,
      String status,
      String expected,
    ) async {
      when(() => getOrderDetails.execute(any())).thenAnswer(
        (_) async => Success(buildDriverOrderDetailsEntity(status: status)),
      );

      await pumpView(tester);
      await tester.pumpAndSettle();

      expect(find.text('status: $expected'), findsOneWidget);
    }

    testWidgets('localizes picked_up', (t) =>
        expectLabel(t, 'picked_up', 'Picked'));
    testWidgets('localizes on_the_way', (t) =>
        expectLabel(t, 'on_the_way', 'Out for delivery'));
    testWidgets('localizes delivered', (t) =>
        expectLabel(t, 'delivered', 'Delivered'));
    testWidgets('falls back to the raw status for unknown values', (t) =>
        expectLabel(t, 'mystery', 'mystery'));
  });
}
