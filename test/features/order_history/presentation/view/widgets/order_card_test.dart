import 'package:driver_app/config/routing/routes.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_formatters.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/order_card.dart';
import 'package:driver_app/l10n/generated/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_data.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('OrderCard', () {
    testWidgets('displays names and navigates to orderDetails on tap',
        (tester) async {
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
      expect(pushedRoute?.settings.name, Routes.orderHistoryDetails);
      expect(pushedRoute?.settings.arguments, 'order123');
    });
  });

  group('OrderCardBody', () {
    testWidgets('displays title, header and address card', (tester) async {
      final order = createOrderHistoryEntity(
        orderId: 'order123',
        store: createOrderStoreEntity(imageUrl: null),
        user: createOrderUserEntity(imageUrl: null),
      );

      await pumpApp(tester, OrderCardBody(order: order));

      expect(find.text(l10n.flowerOrder), findsOneWidget);
      expect(find.text(formatOrderId('order123')), findsOneWidget);
      expect(find.text(l10n.pickupAddress), findsOneWidget);
      expect(find.text(l10n.userAddress), findsOneWidget);
    });
  });

  group('OrderCardAddresses', () {
    testWidgets('displays pickup and user address sections', (tester) async {
      final order = createOrderHistoryEntity(
        store: createOrderStoreEntity(
            name: 'My Store', address: 'Store Address', imageUrl: null),
        user: createOrderUserEntity(
            name: 'My User', address: 'User Address', imageUrl: null),
      );

      await pumpApp(
        tester,
        OrderCardAddresses(order: order),
      );

      expect(find.text(l10n.pickupAddress), findsOneWidget);
      expect(find.text('My Store'), findsOneWidget);
      expect(find.text('Store Address'), findsOneWidget);

      expect(find.text(l10n.userAddress), findsOneWidget);
      expect(find.text('My User'), findsOneWidget);
      expect(find.text('User Address'), findsOneWidget);
    });
  });
}
