import 'package:driver_app/config/errors/app_failure.dart';
import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/order_history/domain/entities/order_history_entities.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_formatters.dart';
import 'package:driver_app/features/order_history/presentation/utils/order_status_ui.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/order_widgets.dart';
import 'package:driver_app/l10n/generated/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

class _Launcher extends StatelessWidget {
  const _Launcher();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const Scaffold(
                  appBar: OrderHistoryAppBar(title: AppStrings.orderDetails),
                ),
              ),
            );
          },
          child: const Text('open'),
        ),
      ),
    );
  }
}

void main() {
  group('OrderHistoryAppBar', () {
    testWidgets('hides the back button when showBack is false', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          appBar: OrderHistoryAppBar(
            title: AppStrings.myOrders,
            showBack: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
      expect(find.text(AppStrings.myOrders), findsOneWidget);
    });

    testWidgets('tapping the back button pops the route', (tester) async {
      await pumpApp(tester, const _Launcher());

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
      expect(find.text(AppStrings.orderDetails), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.text('open'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
    });
  });

  group('OrderStatusLabel', () {
    testWidgets('completed status shows right icon, color, and label',
        (tester) async {
      const status = OrderStatus.completed;
      await pumpApp(
        tester,
        const OrderStatusLabel(
          status: status,
          iconSize: 20,
          spacing: 6,
          textStyle: TextStyle(fontSize: 14),
        ),
      );

      final iconFinder = find.byIcon(status.icon);
      expect(iconFinder, findsOneWidget);
      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.color, status.color);
      expect(find.text(status.label), findsOneWidget);
    });

    testWidgets('cancelled status shows right icon, color, and label',
        (tester) async {
      const status = OrderStatus.cancelled;
      await pumpApp(
        tester,
        const OrderStatusLabel(
          status: status,
          iconSize: 20,
          spacing: 6,
          textStyle: TextStyle(fontSize: 14),
        ),
      );

      final iconFinder = find.byIcon(status.icon);
      expect(iconFinder, findsOneWidget);
      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.color, status.color);
      expect(find.text(status.label), findsOneWidget);
    });
  });

  group('OrderDetailsHeader', () {
    testWidgets(
        'displays formatted orderId and completed status with right icon and color',
        (tester) async {
      const orderId = '12345678';
      const status = OrderStatus.completed;
      await pumpApp(
        tester,
        const OrderDetailsHeader(
          status: status,
          orderId: orderId,
        ),
      );

      expect(find.text(formatOrderId(orderId)), findsOneWidget);
      expect(find.text(status.label), findsOneWidget);

      final iconFinder = find.byIcon(status.icon);
      expect(iconFinder, findsOneWidget);
      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.color, status.color);
    });

    testWidgets(
        'displays formatted orderId and cancelled status with right icon and color',
        (tester) async {
      const orderId = '87654321';
      const status = OrderStatus.cancelled;
      await pumpApp(
        tester,
        const OrderDetailsHeader(
          status: status,
          orderId: orderId,
        ),
      );

      expect(find.text(formatOrderId(orderId)), findsOneWidget);
      expect(find.text(status.label), findsOneWidget);

      final iconFinder = find.byIcon(status.icon);
      expect(iconFinder, findsOneWidget);
      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.color, status.color);
    });
  });

  group('AddressCard', () {
    testWidgets('displays name, address, and location icon', (tester) async {
      await pumpApp(
        tester,
        const AddressCard(
          name: 'Store Name',
          address: '123 Flower St',
          imageUrl: null,
        ),
      );

      expect(find.text('Store Name'), findsOneWidget);
      expect(find.text('123 Flower St'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    });
  });

  group('ErrorMessageView', () {
    final l10n = AppLocalizationsEn();

    testWidgets('shows localized timeout message', (tester) async {
      await pumpApp(tester, const ErrorMessageView(failure: TimeoutFailure()));

      expect(find.text(l10n.failureTimeout), findsOneWidget);
    });

    testWidgets('shows localized internet connection message', (tester) async {
      await pumpApp(
        tester,
        const ErrorMessageView(failure: InternetConnectionFailure()),
      );

      expect(find.text(l10n.failureInternetConnection), findsOneWidget);
    });

    testWidgets('shows localized not found message', (tester) async {
      await pumpApp(
          tester, const ErrorMessageView(failure: NotFoundFailure()));

      expect(find.text(l10n.failureNotFound), findsOneWidget);
    });

    testWidgets('shows server message for BadRequestFailure', (tester) async {
      await pumpApp(
        tester,
        const ErrorMessageView(
          failure:
              BadRequestFailure(serverMessage: 'Server rejected the request'),
        ),
      );

      expect(find.text('Server rejected the request'), findsOneWidget);
    });

    testWidgets('falls back to localized message for empty server message',
        (tester) async {
      await pumpApp(
        tester,
        const ErrorMessageView(failure: BadRequestFailure(serverMessage: '')),
      );

      expect(find.text(l10n.failureBadRequest), findsOneWidget);
    });
  });
}
