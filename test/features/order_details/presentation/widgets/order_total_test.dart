import 'package:driver_app/features/order_details/presentation/widgets/order_total.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_harness.dart';

void main() {
  testWidgets('renders the default label and amount', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(wrapWidget(const OrderTotal()));

    expect(find.text('Total'), findsOneWidget);
    expect(find.text('\$123.45'), findsOneWidget);
  });

  testWidgets('renders a custom label and amount', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(
      wrapWidget(
        const OrderTotal(totalLabel: 'Order total', totalAmount: '\$3,000.00'),
      ),
    );

    expect(find.text('Order total'), findsOneWidget);
    expect(find.text('\$3,000.00'), findsOneWidget);
  });

  testWidgets('renders the label before the amount in the row', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(
      wrapWidget(const OrderTotal(totalLabel: 'Total', totalAmount: '\$10.00')),
    );

    final texts = tester.widgetList<Text>(find.byType(Text)).toList();

    expect(texts.first.data, 'Total');
    expect(texts.last.data, '\$10.00');
  });

  testWidgets('supports an empty label and amount', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(
      wrapWidget(const OrderTotal(totalLabel: '', totalAmount: '')),
    );

    expect(find.text(''), findsNWidgets(2));
  });
}