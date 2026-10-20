import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/orders_empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('OrdersEmpty displays spinner when isLoading is true', (tester) async {
    await pumpApp(tester, const OrdersEmpty(isLoading: true));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(AppStrings.noOrdersYet), findsNothing);
  });

  testWidgets('OrdersEmpty displays noOrdersYet text when isLoading is false', (tester) async {
    await pumpApp(tester, const OrdersEmpty(isLoading: false));
    expect(find.text(AppStrings.noOrdersYet), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
