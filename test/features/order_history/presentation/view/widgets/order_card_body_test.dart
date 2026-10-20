import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_formatters.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/order_card_body.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_data.dart';

void main() {
  testWidgets('OrderCardBody displays title, header and address card', (tester) async {
    final order = createOrderHistoryEntity(
      orderId: 'order123',
      store: createOrderStoreEntity(imageUrl: null),
      user: createOrderUserEntity(imageUrl: null),
    );

    await pumpApp(tester, OrderCardBody(order: order));

    expect(find.text(AppStrings.flowerOrder), findsOneWidget);
    expect(find.text(formatOrderId('order123')), findsOneWidget);
    expect(find.text(AppStrings.pickupAddress), findsOneWidget);
    expect(find.text(AppStrings.userAddress), findsOneWidget);
  });
}
