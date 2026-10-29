import 'dart:async';

import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_details/domain/entities/driver_order_details.dart';
import 'package:driver_app/features/order_details/domain/entities/user_location_entity.dart';
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

import '../../../../helpers/fixtures.dart';

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
  late OrderDetailsCubit cubit;

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

  void mockSuccess({DriverOrderDetailsEntity? entity}) {
    when(() => getOrderDetails.execute(any())).thenAnswer(
      (_) async => Success(entity ?? buildDriverOrderDetailsEntity()),
    );
  }

  void mockFailure() {
    when(() => getOrderDetails.execute(any())).thenAnswer(
      (_) async => Error<DriverOrderDetailsEntity>(const NotFoundFailure()),
    );
  }

  testWidgets('requests order details when the view is built', (tester) async {
    mockSuccess();

    await pumpView(tester);
    await tester.pumpAndSettle();

    verify(() => getOrderDetails.execute(kOrderId)).called(1);
  });

  testWidgets('shows a loading indicator while waiting for data', (
    tester,
  ) async {
    when(() => getOrderDetails.execute(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return Success(buildDriverOrderDetailsEntity());
    });

    await pumpView(tester);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();
  });

  testWidgets('renders loaded order details', (tester) async {
    mockSuccess();

    await pumpView(tester);
    await tester.pumpAndSettle();

    expect(find.text('Order details'), findsWidgets);
    expect(find.text('ORD-12345'), findsOneWidget);
    expect(find.text('Picked'), findsOneWidget);
  });

  testWidgets('renders live GPS tracking badge when tracking is active', (
    tester,
  ) async {
    mockSuccess();

    await pumpView(tester);
    await tester.pumpAndSettle();

    // Since pickedUp starts tracking, verify live tracking badge is shown
    expect(find.text('Live GPS Tracking Active'), findsOneWidget);
  });

  testWidgets('shows a failure message when the load fails', (tester) async {
    mockFailure();

    await pumpView(tester);
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('The requested resource was not found.'), findsWidgets);
  });

  testWidgets('shows warning SnackBar on ShowLocationPermissionDenied event', (
    tester,
  ) async {
    mockSuccess();

    await pumpView(tester);
    await tester.pumpAndSettle();

    cubit.emitEvent(const ShowLocationPermissionDenied());
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text('Location permission is required for live delivery tracking.'),
      findsOneWidget,
    );
  });
}
