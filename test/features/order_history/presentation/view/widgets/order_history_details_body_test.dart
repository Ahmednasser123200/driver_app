import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_history_details_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_history_details_event.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_history_details_state.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_formatters.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/order_history_details_body.dart';
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
  final l10n = AppLocalizationsEn();

  group('OrderHistoryDetailsBody', () {
    late MockOrderHistoryDetailsCubit cubit;

    setUp(() {
      cubit = MockOrderHistoryDetailsCubit();
      stubOrderHistoryDetailsCubit(
        cubit: cubit,
        state: OrderHistoryDetailsState(
          orderDetails: BaseState(data: createOrderHistoryDetailsEntity()),
        ),
      );
    });

    testWidgets('pull to refresh sends GetOrderHistoryDetailsEvent with orderId',
        (tester) async {
      await pumpApp(
        tester,
        BlocProvider<OrderHistoryDetailsCubit>.value(
          value: cubit,
          child: const OrderHistoryDetailsBody(orderId: 'order123'),
        ),
      );

      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      verify(
        () => cubit.doIntent(
          any(
            that: isA<GetOrderHistoryDetailsEvent>().having(
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
      final controller = StreamController<OrderHistoryDetailsState>.broadcast();
      addTearDown(controller.close);

      const loadingState =
          OrderHistoryDetailsState(orderDetails: BaseState(isLoading: true));
      final loadedState = OrderHistoryDetailsState(
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
        BlocProvider<OrderHistoryDetailsCubit>.value(
          value: cubit,
          child: const OrderHistoryDetailsBody(orderId: 'order123'),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      controller.add(loadedState);
      await tester.pump();

      expect(find.byType(OrderHistoryDetailsContent), findsOneWidget);
    });

    testWidgets(
        'state transition loading -> error updates UI to ErrorMessageView',
        (tester) async {
      final controller = StreamController<OrderHistoryDetailsState>.broadcast();
      addTearDown(controller.close);

      const loadingState =
          OrderHistoryDetailsState(orderDetails: BaseState(isLoading: true));
      const errorState = OrderHistoryDetailsState(
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
        BlocProvider<OrderHistoryDetailsCubit>.value(
          value: cubit,
          child: const OrderHistoryDetailsBody(orderId: 'order123'),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      controller.add(errorState);
      await tester.pump();

      expect(find.text(l10n.failureNotFound), findsOneWidget);
    });

    testWidgets('state transition loaded -> error keeps old data on screen',
        (tester) async {
      final controller = StreamController<OrderHistoryDetailsState>.broadcast();
      addTearDown(controller.close);

      final details = createOrderHistoryDetailsEntity(
        store: createOrderStoreEntity(name: 'Existing Details Store'),
      );
      final loadedState = OrderHistoryDetailsState(
        orderDetails: BaseState(isLoading: false, data: details),
      );
      final errorState = OrderHistoryDetailsState(
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
        BlocProvider<OrderHistoryDetailsCubit>.value(
          value: cubit,
          child: const OrderHistoryDetailsBody(orderId: 'order123'),
        ),
      );

      expect(find.text('Existing Details Store'), findsOneWidget);

      controller.add(errorState);
      await tester.pump();

      expect(find.text('Existing Details Store'), findsOneWidget);
    });
  });

  group('OrderHistoryDetailsStateView', () {
    testWidgets('shows a spinner while loading without data', (tester) async {
      await pumpApp(
        tester,
        const OrderHistoryDetailsStateView(
          state: OrderHistoryDetailsState(
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
        const OrderHistoryDetailsStateView(
          state: OrderHistoryDetailsState(failure: NotFoundFailure()),
        ),
      );

      expect(find.text(l10n.failureNotFound), findsOneWidget);
    });

    testWidgets('shows NotFoundFailure ErrorMessageView when data == null, no failure, and not loading',
        (tester) async {
      await pumpApp(
        tester,
        const OrderHistoryDetailsStateView(
          state: OrderHistoryDetailsState(
            orderDetails: BaseState(isLoading: false, data: null),
            failure: null,
          ),
        ),
      );

      expect(find.text(l10n.failureNotFound), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows content when details are available', (tester) async {
      final details = createOrderHistoryDetailsEntity();

      await pumpApp(
        tester,
        OrderHistoryDetailsStateView(
          state: OrderHistoryDetailsState(
            orderDetails: BaseState(data: details),
          ),
        ),
      );

      expect(find.byType(OrderHistoryDetailsContent), findsOneWidget);
    });
  });

  group('OrderHistoryDetailsContent', () {
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

      await pumpApp(tester, OrderHistoryDetailsContent(details: details));

      expect(find.text(l10n.pickupAddress), findsOneWidget);
      expect(find.text(l10n.userAddress), findsOneWidget);
      expect(find.text(l10n.orderDetails), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text(l10n.total),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(
        find.text(formatPrice(details.totalPrice, details.currency)),
        findsOneWidget,
      );
      expect(find.text(l10n.paymentMethod), findsOneWidget);
      expect(find.text(l10n.cashOnDelivery), findsOneWidget);
    });

    testWidgets('shows creditCard payment method for non cash orders',
        (tester) async {
      final details = createOrderHistoryDetailsEntity(isCashOnDelivery: false);

      await pumpApp(tester, OrderHistoryDetailsContent(details: details));

      await tester.scrollUntilVisible(
        find.text(l10n.total),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text(l10n.paymentMethod), findsOneWidget);
      expect(find.text(l10n.creditCard), findsOneWidget);
    });
  });
}
