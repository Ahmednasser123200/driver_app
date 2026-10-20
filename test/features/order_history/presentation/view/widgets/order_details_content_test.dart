import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_formatters.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/order_details_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_data.dart';

void main() {
  testWidgets('renders every section and the total', (tester) async {
    final details = createOrderHistoryDetailsEntity(
      isCashOnDelivery: true,
      items: [
        createOrderItemEntity(
          quantity: 2,
          product: createOrderProductEntity(price: 100, currency: 'EGP'),
        ),
      ],
    );

    await pumpApp(tester, OrderDetailsContent(details: details));

    expect(find.text(AppStrings.pickupAddress), findsOneWidget);
    expect(find.text(AppStrings.userAddress), findsOneWidget);
    expect(find.text(AppStrings.orderDetails), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text(AppStrings.total),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(
      find.text(formatPrice(details.totalPrice, details.currency)),
      findsOneWidget,
    );
    expect(find.text(AppStrings.paymentMethod), findsOneWidget);
  });

  testWidgets('does not show the payment method row for non cash orders', (tester) async {
    final details = createOrderHistoryDetailsEntity(isCashOnDelivery: false);

    await pumpApp(tester, OrderDetailsContent(details: details));

    await tester.scrollUntilVisible(
      find.text(AppStrings.total),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text(AppStrings.paymentMethod), findsNothing);
    expect(find.text(AppStrings.cashOnDelivery), findsNothing);
  });
}
