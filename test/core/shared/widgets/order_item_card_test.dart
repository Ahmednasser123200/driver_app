import 'package:driver_app/core/shared/widgets/order_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/widget_harness.dart';

void main() {
  testWidgets('renders fallback value when product price is empty', (
    tester,
  ) async {
    useDesignSurface(tester);
    await tester.pumpWidget(
      wrapWidget(
        const OrderItemCard(productName: 'Orange', price: '', quantity: 0),
      ),
    );

    expect(find.text('Orange'), findsOneWidget);
    expect(find.text('Unknown'), findsOneWidget);
    expect(find.text('X0'), findsOneWidget);
  });

  testWidgets('renders custom values', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(
      wrapWidget(
        const OrderItemCard(
          productName: 'Red Roses Bouquet',
          price: '\$1500.00',
          quantity: 5,
        ),
      ),
    );

    expect(find.text('Red Roses Bouquet'), findsOneWidget);
    expect(find.text('\$1500.00'), findsOneWidget);
    expect(find.text('X5'), findsOneWidget);
  });

  testWidgets('prefixes the quantity with X', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(
      wrapWidget(
        const OrderItemCard(
          productName: 'Orange',
          price: '\$12.00',
          quantity: 1,
        ),
      ),
    );

    expect(find.text('X1'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('shows a placeholder icon when no image is given', (
    tester,
  ) async {
    useDesignSurface(tester);
    await tester.pumpWidget(
      wrapWidget(
        const OrderItemCard(
          productName: 'Red Roses Bouquet',
          price: '\$1500.00',
          quantity: 1,
        ),
      ),
    );

    expect(find.byIcon(Icons.image), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('renders the image inside a clipped oval when provided', (
    tester,
  ) async {
    useDesignSurface(tester);
    await tester.pumpWidget(
      wrapWidget(
        OrderItemCard(
          productName: 'Red Roses Bouquet',
          price: '\$1500.00',
          quantity: 1,
          productImage: tinyPngImages().first,
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(ClipOval), findsOneWidget);
    expect(find.byIcon(Icons.image), findsNothing);
  });
}
