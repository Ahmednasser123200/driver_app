import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_event.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_state.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/order_card.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/orders_body.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/orders_stats.dart';
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

  group('OrdersBody', () {
    late MockOrdersCubit cubit;

    setUp(() {
      cubit = MockOrdersCubit();
      stubOrdersCubit(
        cubit: cubit,
        state: const OrdersState(
          ordersListState: BaseState(data: OrdersDataState()),
        ),
      );
    });

    testWidgets('pull to refresh sends LoadOrdersEvent', (tester) async {
      await pumpApp(
        tester,
        BlocProvider<OrdersCubit>.value(
          value: cubit,
          child: const OrdersBody(),
        ),
      );

      await tester.fling(
        find.byType(SingleChildScrollView),
        const Offset(0, 300),
        1000,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      verify(() => cubit.doIntent(any(that: isA<LoadOrdersEvent>()))).called(1);
    });

    testWidgets(
        'state transition loading -> loaded updates UI from spinner to content',
        (tester) async {
      final controller = StreamController<OrdersState>.broadcast();
      addTearDown(controller.close);

      const loadingState =
          OrdersState(ordersListState: BaseState(isLoading: true));
      final loadedState = OrdersState(
        ordersListState: BaseState(
          isLoading: false,
          data: OrdersDataState(
            orders: [
              createOrderHistoryEntity(
                store: createOrderStoreEntity(imageUrl: null),
                user: createOrderUserEntity(imageUrl: null),
              ),
            ],
          ),
        ),
      );

      whenListen(
        cubit,
        controller.stream,
        initialState: loadingState,
      );

      await pumpApp(
        tester,
        BlocProvider<OrdersCubit>.value(
          value: cubit,
          child: const OrdersBody(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      controller.add(loadedState);
      await tester.pump();

      expect(find.byType(OrdersContent), findsOneWidget);
    });

    testWidgets('state transition loading -> error updates UI to ErrorMessageView',
        (tester) async {
      final controller = StreamController<OrdersState>.broadcast();
      addTearDown(controller.close);

      const loadingState =
          OrdersState(ordersListState: BaseState(isLoading: true));
      const errorState = OrdersState(
        ordersListState: BaseState(isLoading: false),
        failure: TimeoutFailure(),
      );

      whenListen(
        cubit,
        controller.stream,
        initialState: loadingState,
      );

      await pumpApp(
        tester,
        BlocProvider<OrdersCubit>.value(
          value: cubit,
          child: const OrdersBody(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      controller.add(errorState);
      await tester.pump();

      expect(find.text(AppLocalizationsEn().failureTimeout), findsOneWidget);
    });

    testWidgets('state transition loaded -> error keeps old data on screen',
        (tester) async {
      final controller = StreamController<OrdersState>.broadcast();
      addTearDown(controller.close);

      final dataState = OrdersDataState(
        orders: [
          createOrderHistoryEntity(
            store: createOrderStoreEntity(name: 'Existing Store', imageUrl: null),
            user: createOrderUserEntity(imageUrl: null),
          ),
        ],
      );
      final loadedState = OrdersState(
        ordersListState: BaseState(isLoading: false, data: dataState),
      );
      final errorState = OrdersState(
        ordersListState: BaseState(isLoading: false, data: dataState),
        failure: const TimeoutFailure(),
      );

      whenListen(
        cubit,
        controller.stream,
        initialState: loadedState,
      );

      await pumpApp(
        tester,
        BlocProvider<OrdersCubit>.value(
          value: cubit,
          child: const OrdersBody(),
        ),
      );

      expect(find.text('Existing Store'), findsOneWidget);

      controller.add(errorState);
      await tester.pump();

      expect(find.text('Existing Store'), findsOneWidget);
    });
  });

  group('OrdersStateView', () {
    testWidgets('shows a spinner while loading without data', (tester) async {
      await pumpApp(
        tester,
        const OrdersStateView(
          state: OrdersState(ordersListState: BaseState(isLoading: true)),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows localized error message when loading fails',
        (tester) async {
      await pumpApp(
        tester,
        const OrdersStateView(
          state: OrdersState(
            ordersListState: BaseState(isLoading: false),
            failure: TimeoutFailure(),
          ),
        ),
      );

      expect(
        find.text(AppLocalizationsEn().failureTimeout),
        findsOneWidget,
      );
    });

    testWidgets('shows content when data is available', (tester) async {
      await pumpApp(
        tester,
        const OrdersStateView(
          state: OrdersState(
            ordersListState: BaseState(data: OrdersDataState()),
          ),
        ),
      );

      expect(find.byType(OrdersContent), findsOneWidget);
    });
  });

  group('OrdersContent', () {
    testWidgets(
        'OrdersContent renders stats row and section title, and tapping stat card sends ToggleStatusFilterEvent',
        (tester) async {
      final mockCubit = MockOrdersCubit();
      final state = OrdersState(
        ordersListState: BaseState(
          data: OrdersDataState(
            orders: [
              createOrderHistoryEntity(
                store: createOrderStoreEntity(imageUrl: null),
                user: createOrderUserEntity(imageUrl: null),
              ),
            ],
            completedCount: 1,
            cancelledCount: 0,
          ),
        ),
      );

      stubOrdersCubit(cubit: mockCubit, state: state);

      await pumpApp(
        tester,
        BlocProvider<OrdersCubit>.value(
          value: mockCubit,
          child: OrdersContent(state: state),
        ),
      );

      expect(find.text(AppStrings.recentOrders), findsOneWidget);

      final statCards = find.byType(OrdersStatCard);
      expect(statCards, findsNWidgets(2));

      await tester.tap(statCards.last);
      await tester.pump();

      verify(() => mockCubit.doIntent(any(that: isA<ToggleStatusFilterEvent>())))
          .called(1);
    });
  });

  group('OrdersListArea', () {
    testWidgets('shows OrdersEmpty when visibleOrders is empty',
        (tester) async {
      const state = OrdersState(
        ordersListState:
            BaseState(isLoading: false, data: OrdersDataState(orders: [])),
      );

      await pumpApp(tester, const OrdersListArea(state: state));

      expect(find.text(AppStrings.noOrdersYet), findsOneWidget);
    });

    testWidgets('shows OrdersList when visibleOrders is non-empty',
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
          ),
        ),
      );

      await pumpApp(tester, OrdersListArea(state: state));

      expect(find.byType(OrdersList), findsOneWidget);
    });

    testWidgets('sends LoadMoreOrdersEvent when the list is scrolled near the end',
        (tester) async {
      final cubit = MockOrdersCubit();
      stubOrdersCubit(cubit: cubit);
      final state = OrdersState(
        ordersListState: BaseState(
          data: OrdersDataState(
            orders: List.generate(
              20,
              (i) => createOrderHistoryEntity(
                orderId: '$i',
                store: createOrderStoreEntity(imageUrl: null),
                user: createOrderUserEntity(imageUrl: null),
              ),
            ),
          ),
        ),
      );

      await pumpApp(
        tester,
        BlocProvider<OrdersCubit>.value(
          value: cubit,
          child: OrdersListArea(state: state),
        ),
      );

      await tester.drag(find.byType(ListView), const Offset(0, -10000));
      await tester.pump();

      verify(
        () => cubit.doIntent(any(that: isA<LoadMoreOrdersEvent>())),
      ).called(greaterThanOrEqualTo(1));
    });
  });

  group('OrdersEmpty', () {
    testWidgets('displays spinner when isLoading is true', (tester) async {
      await pumpApp(tester, const OrdersEmpty(isLoading: true));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(AppStrings.noOrdersYet), findsNothing);
    });

    testWidgets('displays noOrdersYet text when isLoading is false',
        (tester) async {
      await pumpApp(tester, const OrdersEmpty(isLoading: false));
      expect(find.text(AppStrings.noOrdersYet), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('OrdersList', () {
    List<OrderHistoryEntity> buildOrders(int count) {
      return List.generate(
        count,
        (i) => createOrderHistoryEntity(
          orderId: '$i',
          store: createOrderStoreEntity(imageUrl: null),
          user: createOrderUserEntity(imageUrl: null),
        ),
      );
    }

    testWidgets('renders cards and loading indicator when isLoadingMore',
        (tester) async {
      await pumpApp(
        tester,
        OrdersList(
          orders: buildOrders(1),
          isLoadingMore: true,
          loadMoreFailed: false,
          onLoadMore: () {},
        ),
      );

      expect(find.byType(OrderCard), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'a drag at the end calls onLoadMore when loadMoreFailed is false',
        (tester) async {
      var loadMoreCalled = false;

      await pumpApp(
        tester,
        OrdersList(
          orders: buildOrders(20),
          isLoadingMore: false,
          loadMoreFailed: false,
          onLoadMore: () => loadMoreCalled = true,
        ),
      );

      await tester.drag(find.byType(ListView), const Offset(0, -10000));
      await tester.pump();

      expect(loadMoreCalled, isTrue);
    });

    testWidgets(
        'with loadMoreFailed true it calls onLoadMore only after the scroll ends',
        (tester) async {
      var loadMoreCallCount = 0;

      await pumpApp(
        tester,
        OrdersList(
          orders: buildOrders(20),
          isLoadingMore: false,
          loadMoreFailed: true,
          onLoadMore: () => loadMoreCallCount++,
        ),
      );

      await tester.drag(find.byType(ListView), const Offset(0, -10000));
      await tester.pumpAndSettle();

      expect(loadMoreCallCount, 1);
    });
  });
}
