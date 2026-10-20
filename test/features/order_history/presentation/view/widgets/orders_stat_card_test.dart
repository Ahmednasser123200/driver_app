import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/orders_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('selected card uses the primary border and tap toggles its status', (tester) async {
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
}
