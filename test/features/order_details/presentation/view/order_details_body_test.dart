import 'dart:async';

import 'package:driver_app/config/base/base_response.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_details/domain/entities/user_location_entity.dart';
import 'package:driver_app/features/order_details/domain/usecases/get_driver_order_details_use_case.dart';
import 'package:driver_app/features/order_details/domain/usecases/report_driver_location_use_case.dart';
import 'package:driver_app/features/order_details/domain/usecases/update_order_status_use_case.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_cubit.dart';
import 'package:driver_app/features/order_details/presentation/manager/cubit/order_details_event.dart';
import 'package:driver_app/features/order_details/presentation/view/order_details_body.dart';
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

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilPlusInit(
        designSize: const Size(375, 700),
        builder: (context, child) => MaterialApp(
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BlocProvider<OrderDetailsCubit>.value(
              value: cubit,
              child: const OrderDetailsBody(orderId: kOrderId),
            ),
          ),
        ),
        child: const SizedBox.shrink(),
      ),
    );
  }

  testWidgets('renders loading indicator when state is loading with no data', (
    tester,
  ) async {
    when(() => getOrderDetails.execute(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return Success(buildDriverOrderDetailsEntity());
    });

    cubit.doEvent(const GetDriverOrderDetailsEvent(orderId: kOrderId));
    await pumpWidget(tester);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 120));
    await tester.pumpAndSettle();
  });

  testWidgets('renders error view with retry button on failure', (tester) async {
    when(
      () => getOrderDetails.execute(any()),
    ).thenAnswer((_) async => Error(const InternetConnectionFailure()));

    await cubit.doEvent(const GetDriverOrderDetailsEvent(orderId: kOrderId));
    await pumpWidget(tester);
    await tester.pumpAndSettle();

    expect(find.byType(OrderDetailsError), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    // Tap retry
    when(
      () => getOrderDetails.execute(any()),
    ).thenAnswer((_) async => Success(buildDriverOrderDetailsEntity()));

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    verify(() => getOrderDetails.execute(kOrderId)).called(2);
    expect(find.byType(OrderDetailsContent), findsOneWidget);
  });

  testWidgets(
    'renders live GPS tracking badge with localized text in English',
    (tester) async {
      when(
        () => getOrderDetails.execute(any()),
      ).thenAnswer((_) async => Success(buildDriverOrderDetailsEntity()));

      await cubit.doEvent(const GetDriverOrderDetailsEvent(orderId: kOrderId));
      await pumpWidget(tester, locale: const Locale('en'));
      await tester.pumpAndSettle();

      expect(find.text('Live GPS Tracking Active'), findsOneWidget);
    },
  );

  testWidgets(
    'renders live GPS tracking badge with localized text in Arabic',
    (tester) async {
      when(
        () => getOrderDetails.execute(any()),
      ).thenAnswer((_) async => Success(buildDriverOrderDetailsEntity()));

      await cubit.doEvent(const GetDriverOrderDetailsEvent(orderId: kOrderId));
      await pumpWidget(tester, locale: const Locale('ar'));
      await tester.pumpAndSettle();

      expect(find.text('تتبع نظام تحديد المواقع مباشر نشط'), findsOneWidget);
    },
  );
}
