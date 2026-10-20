import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_details_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_details_event.dart';
import 'package:driver_app/features/order_history/presentation/manager/order_details_state.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/order_details_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/test_data.dart';

void main() {
  late MockOrderDetailsCubit cubit;

  setUpAll(setupFallbackValues);

  setUp(() {
    cubit = MockOrderDetailsCubit();
    stubOrderDetailsCubit(
      cubit: cubit,
      state: OrderDetailsState(
        orderDetails: BaseState(data: createOrderHistoryDetailsEntity()),
      ),
    );
  });

  testWidgets('pull to refresh sends GetOrderDetailsEvent with orderId', (tester) async {
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
}
