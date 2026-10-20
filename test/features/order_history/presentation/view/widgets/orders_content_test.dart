import 'package:driver_app/config/base/base_state.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_cubit.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_event.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_state.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/orders_content.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/orders_stat_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/test_data.dart';

void main() {
  late MockOrdersCubit mockCubit;

  setUpAll(() {
    setupFallbackValues();
  });

  setUp(() {
    mockCubit = MockOrdersCubit();
  });

  testWidgets('OrdersContent renders stats row and section title, and tapping stat card sends ToggleStatusFilterEvent', (tester) async {
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

    await tester.tap(statCards.last); // completed stat card
    await tester.pump();

    verify(() => mockCubit.doIntent(any(that: isA<ToggleStatusFilterEvent>())))
        .called(1);
  });
}
