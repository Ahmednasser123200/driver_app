import 'package:driver_app/features/order_history/presentation/view/widgets/address_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('AddressCard displays name and address', (tester) async {
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
}
