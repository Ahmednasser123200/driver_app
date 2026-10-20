import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_formatters.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/order_details_header.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('OrderDetailsHeader displays formatted orderId and status label', (tester) async {
    const orderId = '12345678';
    await pumpApp(
      tester,
      const OrderDetailsHeader(
        status: OrderStatus.completed,
        orderId: orderId,
      ),
    );

    expect(find.text(formatOrderId(orderId)), findsOneWidget);
    expect(find.text(AppStrings.statusCompleted), findsOneWidget);
  });
}
