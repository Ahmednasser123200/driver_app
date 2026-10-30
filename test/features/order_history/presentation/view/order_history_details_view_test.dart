import 'dart:async';

import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_history_details_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_history_details_event.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_history_details_state.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_formatters.dart';
import 'package:driver_app/features/order_history/presentation/view/order_history_details_view.dart';
import 'package:driver_app/l10n/generated/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockOrderHistoryDetailsCubit cubit;
  late StreamController<BaseUiEvent> events;
  final l10n = AppLocalizationsEn();

  setUpAll(setupFallbackValues);

  setUp(() {
    cubit = MockOrderHistoryDetailsCubit();
    events = StreamController<BaseUiEvent>.broadcast();
    addTearDown(() async {
      await events.close();
      await getIt.reset();
    });
    stubOrderHistoryDetailsCubit(
      cubit: cubit,
      uiEventController: events,
    );
    getIt.registerFactory<OrderHistoryDetailsCubit>(() => cubit);
  });

  testWidgets('sends GetOrderHistoryDetailsEvent with orderId on create',
      (tester) async {
    await pumpApp(tester, const OrderHistoryDetailsView(orderId: 'order123'));

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
      'renders loading state with spinner when orderDetails is loading without data',
      (tester) async {
    stubOrderHistoryDetailsCubit(
      cubit: cubit,
      state: const OrderHistoryDetailsState(
        orderDetails: BaseState(isLoading: true, data: null),
      ),
      uiEventController: events,
    );

    await pumpApp(tester, const OrderHistoryDetailsView(orderId: 'order123'));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders error state with localized message when failure is present',
      (tester) async {
    stubOrderHistoryDetailsCubit(
      cubit: cubit,
      state: const OrderHistoryDetailsState(
        orderDetails: BaseState(isLoading: false, data: null),
        failure: NotFoundFailure(),
      ),
      uiEventController: events,
    );

    await pumpApp(tester, const OrderHistoryDetailsView(orderId: 'order123'));

    expect(find.text(l10n.failureNotFound), findsOneWidget);
  });

  testWidgets(
      'renders loaded state with store name, user name, item name, quantity, formatted total, and payment method when isCashOnDelivery is true',
      (tester) async {
    final details = createOrderHistoryDetailsEntity(
      orderId: 'order123',
      store: createOrderStoreEntity(name: 'Floral Paradise', imageUrl: null),
      user: createOrderUserEntity(name: 'Bob Marley', imageUrl: null),
      items: [
        createOrderItemEntity(
          quantity: 3,
          product: createOrderProductEntity(
            name: 'Sunflowers',
            price: 50.0,
            currency: 'EGP',
          ),
        ),
      ],
      isCashOnDelivery: true,
    );

    stubOrderHistoryDetailsCubit(
      cubit: cubit,
      state: OrderHistoryDetailsState(
        orderDetails: BaseState(isLoading: false, data: details),
      ),
      uiEventController: events,
    );

    await pumpApp(tester, const OrderHistoryDetailsView(orderId: 'order123'));

    expect(find.text('Floral Paradise'), findsOneWidget);
    expect(find.text('Bob Marley'), findsOneWidget);
    expect(find.text('Sunflowers'), findsOneWidget);
    expect(find.text(formatQuantity(3)), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text(l10n.total),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text(formatPrice(details.totalPrice, details.currency)),
        findsOneWidget);
    expect(find.text(l10n.paymentMethod), findsOneWidget);
    expect(find.text(l10n.cashOnDelivery), findsOneWidget);
  });

  testWidgets(
      'renders loaded state with creditCard payment method when isCashOnDelivery is false',
      (tester) async {
    final details = createOrderHistoryDetailsEntity(
      orderId: 'order123',
      store: createOrderStoreEntity(name: 'Floral Paradise', imageUrl: null),
      user: createOrderUserEntity(name: 'Bob Marley', imageUrl: null),
      items: [
        createOrderItemEntity(
          quantity: 1,
          product: createOrderProductEntity(
            name: 'Tulips',
            price: 40.0,
            currency: 'EGP',
          ),
        ),
      ],
      isCashOnDelivery: false,
    );

    stubOrderHistoryDetailsCubit(
      cubit: cubit,
      state: OrderHistoryDetailsState(
        orderDetails: BaseState(isLoading: false, data: details),
      ),
      uiEventController: events,
    );

    await pumpApp(tester, const OrderHistoryDetailsView(orderId: 'order123'));

    expect(find.text('Floral Paradise'), findsOneWidget);
    expect(find.text('Bob Marley'), findsOneWidget);
    expect(find.text('Tulips'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text(l10n.total),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text(l10n.total), findsOneWidget);
    expect(find.text(l10n.paymentMethod), findsOneWidget);
    expect(find.text(l10n.creditCard), findsOneWidget);
  });

  testWidgets('shows a localized SnackBar when ShowFailure is emitted',
      (tester) async {
    await pumpApp(tester, const OrderHistoryDetailsView(orderId: 'order123'));

    events.add(const ShowFailure(NotFoundFailure()));
    await tester.pump();
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text(l10n.failureNotFound),
      ),
      findsOneWidget,
    );
  });
}
