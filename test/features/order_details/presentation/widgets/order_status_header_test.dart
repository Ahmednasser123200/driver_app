import 'package:driver_app/features/order_details/presentation/widgets/order_status_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_harness.dart';

void main() {
  testWidgets('renders the default status, order id and date', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(wrapWidget(const OrderStatusHeader()));

    expect(find.text('status: Accepted'), findsOneWidget);
    expect(find.text('Order ID: # 123456'), findsOneWidget);
    expect(find.text('Wed, 03 Sep 2024, 11:00 AM '), findsOneWidget);
  });

  testWidgets('renders custom status, order id and date', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(
      wrapWidget(
        const OrderStatusHeader(
          status: 'OutForDelivery',
          orderId: 'bbbb2222-0002-0002-0002-000000000002',
          date: 'Sat, 19 Sep 2026, 06:00 PM',
        ),
      ),
    );

    expect(find.text('status: OutForDelivery'), findsOneWidget);
    expect(
      find.text('Order ID: bbbb2222-0002-0002-0002-000000000002'),
      findsOneWidget,
    );
    expect(find.text('Sat, 19 Sep 2026, 06:00 PM'), findsOneWidget);
  });

  testWidgets('prefixes the status and order id labels', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(
      wrapWidget(
        const OrderStatusHeader(status: 'PickedUp', orderId: 'abc'),
      ),
    );

    expect(find.textContaining('status:'), findsOneWidget);
    expect(find.textContaining('Order ID:'), findsOneWidget);
  });

  testWidgets('renders exactly three text lines', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(wrapWidget(const OrderStatusHeader()));

    expect(find.byType(Text), findsNWidgets(3));
  });
}