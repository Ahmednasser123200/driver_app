import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/items_section.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/order_item_card.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_data.dart';

void main() {
  testWidgets('renders a card per item under the section title', (tester) async {
    final items = [
      createOrderItemEntity(productId: 'p1', quantity: 2),
      createOrderItemEntity(productId: 'p2', quantity: 1),
    ];

    await pumpApp(tester, ItemsSection(items: items));

    expect(find.text(AppStrings.orderDetails), findsOneWidget);
    expect(find.byType(OrderItemCard), findsNWidgets(2));
  });
}
