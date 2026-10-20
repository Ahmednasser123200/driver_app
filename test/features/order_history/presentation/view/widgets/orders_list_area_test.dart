import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_event.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_state.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/orders_list.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/orders_list_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/test_data.dart';

void main() {
  setUpAll(setupFallbackValues);

  testWidgets('OrdersListArea shows OrdersEmpty when visibleOrders is empty', (tester) async {
    const state = OrdersState(
      ordersListState: BaseState(isLoading: false, data: OrdersDataState(orders: [])),
    );

    await pumpApp(tester, const OrdersListArea(state: state));

    expect(find.text(AppStrings.noOrdersYet), findsOneWidget);
  });

  testWidgets('OrdersListArea shows OrdersList when visibleOrders is non-empty', (tester) async {
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

  testWidgets('sends LoadMoreOrdersEvent when the list is scrolled near the end', (tester) async {
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
}
