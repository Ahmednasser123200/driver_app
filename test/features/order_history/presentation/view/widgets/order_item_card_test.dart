import 'package:driver_app/features/order_history/presentation/utils/order_formatters.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/order_item_card.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_data.dart';

void main() {
  testWidgets('shows product name, quantity and formatted price', (tester) async {
    final product = createOrderProductEntity(
      name: 'Red Roses',
      price: 99.5,
      currency: 'EGP',
    );
    final item = createOrderItemEntity(
      quantity: 3,
      product: product,
    );

    await pumpApp(tester, OrderItemCard(item: item));

    expect(find.text('Red Roses'), findsOneWidget);
    expect(find.text(formatQuantity(3)), findsOneWidget);
    expect(find.text(formatPrice(product.price, product.currency)), findsOneWidget);
  });
}
