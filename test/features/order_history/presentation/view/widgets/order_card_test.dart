import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_data.dart';

void main() {
  testWidgets('OrderCard displays names and navigates to orderDetails on tap', (tester) async {
    final order = createOrderHistoryEntity(
      orderId: 'order123',
      store: createOrderStoreEntity(name: 'Store Name', imageUrl: null),
      user: createOrderUserEntity(name: 'User Name', imageUrl: null),
    );

    Route<dynamic>? pushedRoute;
    await pumpApp(
      tester,
      OrderCard(order: order),
      onGenerateRoute: (settings) {
        pushedRoute = MaterialPageRoute(
          settings: settings,
          builder: (_) => const SizedBox(),
        );
        return pushedRoute;
      },
    );

    expect(find.text('Store Name'), findsOneWidget);
    expect(find.text('User Name'), findsOneWidget);

    await tester.tap(find.byType(OrderCard));
    await tester.pump();

    expect(pushedRoute, isNotNull);
    expect(pushedRoute?.settings.name, Routes.orderDetails);
    expect(pushedRoute?.settings.arguments, 'order123');
  });
}
