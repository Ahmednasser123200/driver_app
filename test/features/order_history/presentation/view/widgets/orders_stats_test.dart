import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/manager/orders_state.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/orders_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OrdersStatsRow', () {
    testWidgets('displays counts for cancelled and completed and handles tap',
        (tester) async {
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

      await tester.tap(cards.first);
      expect(toggledStatus, OrderStatus.cancelled);
    });
  });

  group('OrdersStatCard', () {
    testWidgets(
        'selected card uses the primary border and tap toggles its status',
        (tester) async {
      OrderStatus? toggled;

      await pumpApp(
        tester,
        OrdersStatCard(
          status: OrderStatus.completed,
          count: 4,
          selected: OrderStatus.completed,
          onToggle: (status) => toggled = status,
        ),
      );

      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(OrdersStatCard),
              matching: find.byType(Material),
            )
            .first,
      );
      final shape = material.shape! as RoundedRectangleBorder;
      expect(shape.side.color, AppColors.primary);

      await tester.tap(find.byType(OrdersStatCard));
      expect(toggled, OrderStatus.completed);
    });

    testWidgets('unselected card uses a transparent border', (tester) async {
      await pumpApp(
        tester,
        OrdersStatCard(
          status: OrderStatus.cancelled,
          count: 2,
          selected: OrderStatus.completed,
          onToggle: (_) {},
        ),
      );

      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(OrdersStatCard),
              matching: find.byType(Material),
            )
            .first,
      );
      final shape = material.shape! as RoundedRectangleBorder;
      expect(shape.side.color, AppColors.transparent);
    });
  });

  group('OrdersStatCardBody', () {
    testWidgets('shows the count and the cancelled status label',
        (tester) async {
      await pumpApp(
        tester,
        const OrdersStatCardBody(
          status: OrderStatus.cancelled,
          count: 7,
        ),
      );

      expect(find.text('7'), findsOneWidget);
      expect(find.text(AppStrings.statusCancelled), findsOneWidget);
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    });

    testWidgets('shows the completed status label', (tester) async {
      await pumpApp(
        tester,
        const OrdersStatCardBody(
          status: OrderStatus.completed,
          count: 2,
        ),
      );

      expect(find.text('2'), findsOneWidget);
      expect(find.text(AppStrings.statusCompleted), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });
  });
}
