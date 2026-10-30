import 'package:driver_app/features/order_history/presentation/utils/order_formatters.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/order_history_details_sections.dart';
import 'package:driver_app/l10n/generated/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_data.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('PickupSection', () {
    testWidgets('renders section title and store address card', (tester) async {
      final store = createOrderStoreEntity(
        name: 'Pickup Store',
        address: 'Pickup Street',
        imageUrl: null,
      );

      await pumpApp(tester, PickupSection(store: store));

      expect(find.text(l10n.pickupAddress), findsOneWidget);
      expect(find.text('Pickup Store'), findsOneWidget);
      expect(find.text('Pickup Street'), findsOneWidget);
    });
  });

  group('UserSection', () {
    testWidgets('renders section title and user address card', (tester) async {
      final user = createOrderUserEntity(
        name: 'Recipient',
        address: 'Recipient Street',
        imageUrl: null,
      );

      await pumpApp(tester, UserSection(user: user));

      expect(find.text(l10n.userAddress), findsOneWidget);
      expect(find.text('Recipient'), findsOneWidget);
      expect(find.text('Recipient Street'), findsOneWidget);
    });
  });

  group('ItemsSection', () {
    testWidgets('renders a card per item under the section title',
        (tester) async {
      final items = [
        createOrderItemEntity(productId: 'p1', quantity: 2),
        createOrderItemEntity(productId: 'p2', quantity: 1),
      ];

      await pumpApp(tester, ItemsSection(items: items));

      expect(find.text(l10n.orderDetails), findsOneWidget);
      expect(find.byType(OrderItemCard), findsNWidgets(2));
    });

    testWidgets('shows NotFoundFailure message when items is empty',
        (tester) async {
      await pumpApp(tester, const ItemsSection(items: []));

      expect(find.text(l10n.orderDetails), findsOneWidget);
      expect(find.text(l10n.failureNotFound), findsOneWidget);
      expect(find.byType(OrderItemCard), findsNothing);
    });
  });

  group('SummarySection', () {
    testWidgets('shows formatted total and payment method when cash on delivery',
        (tester) async {
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

      expect(
          find.text(formatPrice(details.totalPrice, details.currency)), findsOneWidget);
      expect(find.text(l10n.paymentMethod), findsOneWidget);
      expect(find.text(l10n.cashOnDelivery), findsOneWidget);
    });

    testWidgets('shows creditCard when not cash on delivery',
        (tester) async {
      final details = createOrderHistoryDetailsEntity(isCashOnDelivery: false);

      await pumpApp(tester, SummarySection(details: details));

      expect(find.text(l10n.total), findsOneWidget);
      expect(find.text(l10n.paymentMethod), findsOneWidget);
      expect(find.text(l10n.creditCard), findsOneWidget);
    });
  });

  group('SummaryRow', () {
    testWidgets('SummaryRow displays label and value', (tester) async {
      await pumpApp(tester, const SummaryRow(label: 'Total', value: 'EGP 100'));
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('EGP 100'), findsOneWidget);
    });
  });

  group('OrderItemCard', () {
    testWidgets('shows product name, quantity and formatted price',
        (tester) async {
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
      expect(find.text(formatPrice(product.price, product.currency)),
          findsOneWidget);
    });
  });
}
