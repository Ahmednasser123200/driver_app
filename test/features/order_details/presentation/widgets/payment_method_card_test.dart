import 'package:driver_app/features/order_details/presentation/widgets/payment_method_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_harness.dart';

void main() {
  testWidgets('renders the default title and method', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(wrapWidget(const PaymentMethodCard()));

    expect(find.text('Payment Method'), findsOneWidget);
    expect(find.text('Credit Card'), findsOneWidget);
  });

  testWidgets('renders a custom title and method', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(
      wrapWidget(
        const PaymentMethodCard(title: 'Payment', method: 'Cash on delivery'),
      ),
    );

    expect(find.text('Payment'), findsOneWidget);
    expect(find.text('Cash on delivery'), findsOneWidget);
  });

  testWidgets('renders the title before the method in the row', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(
      wrapWidget(const PaymentMethodCard(title: 'Payment', method: 'COD')),
    );

    final texts = tester.widgetList<Text>(find.byType(Text)).toList();

    expect(texts.first.data, 'Payment');
    expect(texts.last.data, 'COD');
  });
}