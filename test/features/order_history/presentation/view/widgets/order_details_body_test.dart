import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_details_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_details_event.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_details_state.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_formatters.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/order_details_body.dart';
import 'package:driver_app/l10n/generated/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/test_data.dart';

void main() {
  setUpAll(setupFallbackValues);

  group('OrderDetailsBody', () {
    late MockOrderDetailsCubit cubit;

    setUp(() {
      cubit = MockOrderDetailsCubit();
      stubOrderDetailsCubit(
        cubit: cubit,
        state: OrderDetailsState(
          orderDetails: BaseState(data: createOrderHistoryDetailsEntity()),
        ),
      );
    });

    testWidgets('pull to refresh sends GetOrderDetailsEvent with orderId',
        (tester) async {
      await pumpApp(
        tester,
        BlocProvider<OrderDetailsCubit>.value(
          value: cubit,
          child: const OrderDetailsBody(orderId: 'order123'),
        ),
      );

      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      verify(
        () => cubit.doIntent(
          any(
            that: isA<GetOrderDetailsEvent>().having(
              (event) => event.orderId,
              'orderId',
              'order123',
            ),
          ),
        ),
      ).called(1);
    });

    testWidgets(
        'state transition loading -> loaded updates UI from spinner to content',
        (tester) async {
      final controller = StreamController<OrderDetailsState>.broadcast();
      addTearDown(controller.close);

      const loadingState =
          OrderDetailsState(orderDetails: BaseState(isLoading: true));
      final loadedState = OrderDetailsState(
        orderDetails: BaseState(
          isLoading: false,
          data: createOrderHistoryDetailsEntity(),
        ),
      );

      whenListen(
        cubit,
        controller.stream,
        initialState: loadingState,
      );

      await pumpApp(
        tester,
        BlocProvider<OrderDetailsCubit>.value(
          value: cubit,
          child: const OrderDetailsBody(orderId: 'order123'),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      controller.add(loadedState);
      await tester.pump();

      expect(find.byType(OrderDetailsContent), findsOneWidget);
    });

    testWidgets(
        'state transition loading -> error updates UI to ErrorMessageView',
        (tester) async {
      final controller = StreamController<OrderDetailsState>.broadcast();
      addTearDown(controller.close);

      const loadingState =
          OrderDetailsState(orderDetails: BaseState(isLoading: true));
      const errorState = OrderDetailsState(
        orderDetails: BaseState(isLoading: false),
        failure: NotFoundFailure(),
      );

      whenListen(
        cubit,
        controller.stream,
        initialState: loadingState,
      );

      await pumpApp(
        tester,
        BlocProvider<OrderDetailsCubit>.value(
          value: cubit,
          child: const OrderDetailsBody(orderId: 'order123'),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      controller.add(errorState);
      await tester.pump();

      expect(find.text(AppLocalizationsEn().failureNotFound), findsOneWidget);
    });

    testWidgets('state transition loaded -> error keeps old data on screen',
        (tester) async {
      final controller = StreamController<OrderDetailsState>.broadcast();
      addTearDown(controller.close);

      final details = createOrderHistoryDetailsEntity(
        store: createOrderStoreEntity(name: 'Existing Details Store'),
      );
      final loadedState = OrderDetailsState(
        orderDetails: BaseState(isLoading: false, data: details),
      );
      final errorState = OrderDetailsState(
        orderDetails: BaseState(isLoading: false, data: details),
        failure: const TimeoutFailure(),
      );

      whenListen(
        cubit,
        controller.stream,
        initialState: loadedState,
      );

      await pumpApp(
        tester,
        BlocProvider<OrderDetailsCubit>.value(
          value: cubit,
          child: const OrderDetailsBody(orderId: 'order123'),
        ),
      );

      expect(find.text('Existing Details Store'), findsOneWidget);

      controller.add(errorState);
      await tester.pump();

      expect(find.text('Existing Details Store'), findsOneWidget);
    });
  });

  group('OrderDetailsStateView', () {
    testWidgets('shows a spinner while loading without data', (tester) async {
      await pumpApp(
        tester,
        const OrderDetailsStateView(
          state: OrderDetailsState(
            orderDetails: BaseState(isLoading: true),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows localized error message when loading fails',
        (tester) async {
      await pumpApp(
        tester,
        const OrderDetailsStateView(
          state: OrderDetailsState(failure: NotFoundFailure()),
        ),
      );

      expect(find.text(AppLocalizationsEn().failureNotFound), findsOneWidget);
    });

    testWidgets('shows content when details are available', (tester) async {
      final details = createOrderHistoryDetailsEntity();

      await pumpApp(
        tester,
        OrderDetailsStateView(
          state: OrderDetailsState(
            orderDetails: BaseState(data: details),
          ),
        ),
      );

      expect(find.byType(OrderDetailsContent), findsOneWidget);
    });
  });

  group('OrderDetailsContent', () {
    testWidgets('renders every section and the total', (tester) async {
      final details = createOrderHistoryDetailsEntity(
        isCashOnDelivery: true,
        items: [
          createOrderItemEntity(
            quantity: 2,
            product: createOrderProductEntity(price: 100, currency: 'EGP'),
          ),
        ],
      );

      await pumpApp(tester, OrderDetailsContent(details: details));

      expect(find.text(AppStrings.pickupAddress), findsOneWidget);
      expect(find.text(AppStrings.userAddress), findsOneWidget);
      expect(find.text(AppStrings.orderDetails), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text(AppStrings.total),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(
        find.text(formatPrice(details.totalPrice, details.currency)),
        findsOneWidget,
      );
      expect(find.text(AppStrings.paymentMethod), findsOneWidget);
    });

    testWidgets('does not show the payment method row for non cash orders',
        (tester) async {
      final details = createOrderHistoryDetailsEntity(isCashOnDelivery: false);

      await pumpApp(tester, OrderDetailsContent(details: details));

      await tester.scrollUntilVisible(
        find.text(AppStrings.total),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text(AppStrings.paymentMethod), findsNothing);
      expect(find.text(AppStrings.cashOnDelivery), findsNothing);
    });
  });
}
