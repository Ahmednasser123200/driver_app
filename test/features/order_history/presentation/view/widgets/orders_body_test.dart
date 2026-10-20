import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_event.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_state.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/orders_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late MockOrdersCubit cubit;

  setUpAll(setupFallbackValues);

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
}
