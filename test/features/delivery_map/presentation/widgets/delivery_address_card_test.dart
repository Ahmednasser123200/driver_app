import 'package:driver_app/features/delivery_map/presentation/widgets/delivery_address_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../helpers/widget_harness.dart';

void main() {
  group('DeliveryAddressCard', () {
    testWidgets('renders store variant with title and address', (tester) async {
      useDesignSurface(tester);

      var cardTapped = false;
      var callTapped = false;
      var whatsAppTapped = false;

      await tester.pumpWidget(
        wrapWidget(
          SizedBox(
            width: 350,
            child: DeliveryAddressCard(
              title: 'Flowery store',
              address: '20th st, Sheikh Zayed, Giza',
              isStore: true,
              isSelected: true,
              onTap: () => cardTapped = true,
              onCallPressed: () => callTapped = true,
              onWhatsAppPressed: () => whatsAppTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Flowery store'), findsOneWidget);
      expect(find.text('20th st, Sheikh Zayed, Giza'), findsOneWidget);
      expect(find.text('Flowery'), findsOneWidget);
      expect(find.byIcon(Icons.call_outlined), findsOneWidget);
      expect(find.byType(FaIcon), findsOneWidget);

      await tester.tap(find.text('Flowery store'));
      await tester.pump();
      expect(cardTapped, isTrue);

      await tester.tap(find.byIcon(Icons.call_outlined));
      await tester.pump();
      expect(callTapped, isTrue);

      await tester.tap(find.byType(FaIcon));
      await tester.pump();
      expect(whatsAppTapped, isTrue);
    });

    testWidgets('renders user variant with person icon when no image', (tester) async {
      useDesignSurface(tester);

      await tester.pumpWidget(
        wrapWidget(
          const SizedBox(
            width: 350,
            child: DeliveryAddressCard(
              title: 'Nour mohamed',
              address: '20th st, Sheikh Zayed, Giza',
              isStore: false,
              isSelected: false,
            ),
          ),
        ),
      );

      expect(find.text('Nour mohamed'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });
}
