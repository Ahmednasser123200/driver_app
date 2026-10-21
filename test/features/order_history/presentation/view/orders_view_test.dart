import 'dart:async';

import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/base/base_ui_event.dart';
import 'package:driver_app/config/di/di.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_event.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_state.dart';
import 'package:driver_app/features/order_history/presentation/view/orders_view.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/orders_stats.dart';
import 'package:driver_app/l10n/generated/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockOrdersCubit cubit;
  late StreamController<BaseUiEvent> events;

  setUpAll(setupFallbackValues);

  setUp(() {
    cubit = MockOrdersCubit();
    events = StreamController<BaseUiEvent>.broadcast();
    addTearDown(() async {
      await events.close();
      await getIt.reset();
    });
    stubOrdersCubit(
      cubit: cubit,
      uiEventController: events,
    );
    getIt.registerFactory<OrdersCubit>(() => cubit);
  });

  testWidgets('sends LoadOrdersEvent on create', (tester) async {
    await pumpApp(tester, const OrdersView());

    verify(() => cubit.doIntent(any(that: isA<LoadOrdersEvent>()))).called(1);
  });

  testWidgets(
      'renders loading state with spinner when ordersListState is loading without data',
      (tester) async {
    stubOrdersCubit(
      cubit: cubit,
      state: const OrdersState(
        ordersListState: BaseState(isLoading: true, data: null),
      ),
      uiEventController: events,
    );

    await pumpApp(tester, const OrdersView());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
      'renders empty state with AppStrings.noOrdersYet when orders is empty',
      (tester) async {
    stubOrdersCubit(
      cubit: cubit,
      state: const OrdersState(
        ordersListState: BaseState(
          isLoading: false,
          data: OrdersDataState(orders: []),
        ),
      ),
      uiEventController: events,
    );

    await pumpApp(tester, const OrdersView());

    expect(find.text(AppStrings.noOrdersYet), findsOneWidget);
  });

  testWidgets(
      'renders error state with localized message through ErrorMessageView when failure is present',
      (tester) async {
    stubOrdersCubit(
      cubit: cubit,
      state: const OrdersState(
        ordersListState: BaseState(isLoading: false, data: null),
        failure: TimeoutFailure(),
      ),
      uiEventController: events,
    );

    await pumpApp(tester, const OrdersView());

    expect(find.text(AppLocalizationsEn().failureTimeout), findsOneWidget);
  });

  testWidgets(
      'renders loaded state with store name, user name, and both status counters',
      (tester) async {
    final state = OrdersState(
      ordersListState: BaseState(
        isLoading: false,
        data: OrdersDataState(
          orders: [
            createOrderHistoryEntity(
              store: createOrderStoreEntity(
                  name: 'Flower Shop', imageUrl: null),
              user: createOrderUserEntity(name: 'Alice Smith', imageUrl: null),
            ),
          ],
          completedCount: 8,
          cancelledCount: 3,
        ),
      ),
    );

    stubOrdersCubit(
      cubit: cubit,
      state: state,
      uiEventController: events,
    );

    await pumpApp(tester, const OrdersView());

    expect(find.text('Flower Shop'), findsOneWidget);
    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('tapping a status card sends ToggleStatusFilterEvent',
      (tester) async {
    final state = OrdersState(
      ordersListState: BaseState(
        isLoading: false,
        data: OrdersDataState(
          orders: [
            createOrderHistoryEntity(
              store: createOrderStoreEntity(imageUrl: null),
              user: createOrderUserEntity(imageUrl: null),
            ),
          ],
          completedCount: 5,
          cancelledCount: 2,
        ),
      ),
    );

    stubOrdersCubit(
      cubit: cubit,
      state: state,
      uiEventController: events,
    );

    await pumpApp(tester, const OrdersView());

    final statCards = find.byType(OrdersStatCard);
    expect(statCards, findsNWidgets(2));

    await tester.tap(statCards.last);
    await tester.pump();

    verify(() => cubit.doIntent(any(that: isA<ToggleStatusFilterEvent>())))
        .called(1);
  });

  testWidgets('shows a localized SnackBar when ShowFailure is emitted',
      (tester) async {
    await pumpApp(tester, const OrdersView());

    events.add(const ShowFailure(TimeoutFailure()));
    await tester.pump();
    await tester.pump();

    expect(
      find.text(AppLocalizationsEn().failureTimeout),
      findsOneWidget,
    );
  });
}
