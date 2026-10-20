import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/order_status_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('OrderStatusLabel displays icon and label text', (tester) async {
    await pumpApp(
      tester,
      const OrderStatusLabel(
        status: OrderStatus.completed,
        iconSize: 20,
        spacing: 6,
        textStyle: TextStyle(fontSize: 14),
      ),
    );

    expect(find.byType(Icon), findsOneWidget);
    expect(find.text(AppStrings.statusCompleted), findsOneWidget);
  });
}
