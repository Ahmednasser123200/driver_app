import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/order_card_addresses.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_data.dart';

void main() {
  testWidgets('OrderCardAddresses displays pickup and user address sections', (tester) async {
    final order = createOrderHistoryEntity(
      store: createOrderStoreEntity(name: 'My Store', address: 'Store Address', imageUrl: null),
      user: createOrderUserEntity(name: 'My User', address: 'User Address', imageUrl: null),
    );

    await pumpApp(
      tester,
      OrderCardAddresses(order: order),
    );

    expect(find.text(AppStrings.pickupAddress), findsOneWidget);
    expect(find.text('My Store'), findsOneWidget);
    expect(find.text('Store Address'), findsOneWidget);

    expect(find.text(AppStrings.userAddress), findsOneWidget);
    expect(find.text('My User'), findsOneWidget);
    expect(find.text('User Address'), findsOneWidget);
  });
}
