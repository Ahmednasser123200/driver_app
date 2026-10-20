import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_formatters.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/summary_section.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_data.dart';

void main() {
  testWidgets('shows formatted total and payment method when cash on delivery', (tester) async {
    final details = createOrderHistoryDetailsEntity(
      isCashOnDelivery: true,
      items: [
        createOrderItemEntity(
          quantity: 2,
          product: createOrderProductEntity(price: 100, currency: 'EGP'),
        ),
      ],
    );

    await pumpApp(tester, SummarySection(details: details));

    expect(find.text(formatPrice(details.totalPrice, details.currency)), findsOneWidget);
    expect(find.text(AppStrings.paymentMethod), findsOneWidget);
    expect(find.text(AppStrings.cashOnDelivery), findsOneWidget);
  });

  testWidgets('hides payment method row when not cash on delivery', (tester) async {
    final details = createOrderHistoryDetailsEntity(isCashOnDelivery: false);

    await pumpApp(tester, SummarySection(details: details));

    expect(find.text(AppStrings.total), findsOneWidget);
    expect(find.text(AppStrings.paymentMethod), findsNothing);
    expect(find.text(AppStrings.cashOnDelivery), findsNothing);
  });
}
