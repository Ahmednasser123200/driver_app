import 'package:driver_app/features/home/presentation/widgets/information_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../home_test_fixtures.dart';

void main() {
  setUpAll(mockNetworkImages);
  tearDownAll(restoreNetworkImages);

  testWidgets('renders the title, address and location icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InformationCard(
            image: 'https://example.com/store.png',
            title: 'Flowery Store',
            address: '20th st, Sheikh Zayed, Giza',
            theme: ThemeData(),
          ),
        ),
      ),
    );

    expect(find.text('Flowery Store'), findsOneWidget);
    expect(find.text('20th st, Sheikh Zayed, Giza'), findsOneWidget);
    expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
  });
}
