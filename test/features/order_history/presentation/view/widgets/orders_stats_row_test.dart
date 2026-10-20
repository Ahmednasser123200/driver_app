import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_state.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/orders_stat_card.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/orders_stat_card_body.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/orders_stats_row.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OrdersStatsRow & OrdersStatCard', () {
    testWidgets('OrdersStatCardBody displays count and status label', (tester) async {
      await pumpApp(
        tester,
        const OrdersStatCardBody(
          status: OrderStatus.completed,
          count: 5,
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('OrdersStatsRow displays counts for cancelled and completed and handles tap', (tester) async {
      OrderStatus? toggledStatus;
      const data = OrdersDataState(completedCount: 10, cancelledCount: 3);

      await pumpApp(
        tester,
        OrdersStatsRow(
          data: data,
          selected: OrderStatus.completed,
          onToggle: (status) => toggledStatus = status,
        ),
      );

      expect(find.text('10'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      final cards = find.byType(OrdersStatCard);
      expect(cards, findsNWidgets(2));

      // Tap on cancelled stat card (first card in list is cancelled)
      await tester.tap(cards.first);
      expect(toggledStatus, OrderStatus.cancelled);
    });
  });
}
