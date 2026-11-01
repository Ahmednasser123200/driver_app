import 'package:driver_app/features/delivery_map/presentation/widgets/delivery_map_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_harness.dart';

void main() {
  group('DeliveryMapBackButton', () {
    testWidgets('renders back button and responds to tap', (tester) async {
      useDesignSurface(tester);

      var pressed = false;
      await tester.pumpWidget(
        wrapWidget(
          DeliveryMapBackButton(
            onPressed: () => pressed = true,
          ),
        ),
      );

      expect(find.byType(DeliveryMapBackButton), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);

      await tester.tap(find.byType(DeliveryMapBackButton));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });
  });
}
