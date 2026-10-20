import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/orders_stat_card_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the count and the cancelled status label', (tester) async {
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
}
