import 'package:driver_app/features/order_details/presentation/widgets/order_status_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_harness.dart';

void main() {
  testWidgets('renders the provided status, order id and date', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(
      wrapWidget(
        const OrderStatusHeader(
          status: 'Accepted',
          orderId: '#123456',
          date: 'Wed, 03 Sep 2024, 11:00 AM',
        ),
      ),
    );

    expect(find.text('Accepted'), findsOneWidget);
    expect(find.text('#123456'), findsOneWidget);
    expect(find.text('Wed, 03 Sep 2024, 11:00 AM'), findsOneWidget);
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

    expect(find.text('OutForDelivery'), findsOneWidget);
    expect(find.text('bbbb2222-0002-0002-0002-000000000002'), findsOneWidget);
    expect(find.text('Sat, 19 Sep 2026, 06:00 PM'), findsOneWidget);
  });

  testWidgets('renders all three text values without labels', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(
      wrapWidget(
        const OrderStatusHeader(
          status: 'PickedUp',
          orderId: 'abc',
          date: '09 Sep 2026',
        ),
      ),
    );

    expect(find.text('PickedUp'), findsOneWidget);
    expect(find.text('abc'), findsOneWidget);
    expect(find.text('09 Sep 2026'), findsOneWidget);
  });

  testWidgets('renders exactly three text lines', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(
      wrapWidget(
        const OrderStatusHeader(
          status: 'Accepted',
          orderId: '#123456',
          date: 'Wed, 03 Sep 2024, 11:00 AM',
        ),
      ),
    );

    expect(find.byType(Text), findsNWidgets(3));
  });
}
