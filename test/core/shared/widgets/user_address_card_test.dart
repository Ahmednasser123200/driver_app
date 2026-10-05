import 'package:driver_app/core/shared/widgets/user_address_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../helpers/widget_harness.dart';

void main() {
  testWidgets('renders the default name and address', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(wrapWidget(const UserAddressCard()));

    expect(find.text('User Name'), findsOneWidget);
    expect(find.text('Address'), findsOneWidget);
  });

  testWidgets('renders custom values', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(
      wrapWidget(
        const UserAddressCard(
          userName: 'Nour Mohamed',
          address: '20th st, Sheikh Zayed',
        ),
      ),
    );

    expect(find.text('Nour Mohamed'), findsOneWidget);
    expect(find.text('20th st, Sheikh Zayed'), findsOneWidget);
  });

  testWidgets('shows a placeholder icon when no avatar is given', (
    tester,
  ) async {
    useDesignSurface(tester);
    await tester.pumpWidget(wrapWidget(const UserAddressCard()));

    expect(find.byIcon(Icons.image), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('renders the avatar when provided', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(
      wrapWidget(UserAddressCard(userImage: tinyPngImages().first)),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.image), findsNothing);
  });

  group('actions', () {
    testWidgets('exposes call and WhatsApp buttons', (tester) async {
      useDesignSurface(tester);
      await tester.pumpWidget(wrapWidget(const UserAddressCard()));

      expect(find.byIcon(Icons.call), findsOneWidget);
      expect(find.byType(FaIcon), findsOneWidget);
      expect(
        tester.widget<FaIcon>(find.byType(FaIcon)).icon?.codePoint,
        FontAwesomeIcons.whatsapp.codePoint,
      );
    });

    testWidgets('invokes onCallPressed', (tester) async {
      var calls = 0;
      useDesignSurface(tester);
      await tester.pumpWidget(
        wrapWidget(UserAddressCard(onCallPressed: () => calls++)),
      );

      await tester.tap(find.byIcon(Icons.call));
      await tester.pump();

      expect(calls, 1);
    });

    testWidgets('invokes onWhatsAppPressed', (tester) async {
      var taps = 0;
      useDesignSurface(tester);
      await tester.pumpWidget(
        wrapWidget(UserAddressCard(onWhatsAppPressed: () => taps++)),
      );

      await tester.tap(find.byType(FaIcon));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('disables both actions when callbacks are null', (
      tester,
    ) async {
      useDesignSurface(tester);
      await tester.pumpWidget(wrapWidget(const UserAddressCard()));

      final call = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.call),
          matching: find.byType(IconButton),
        ),
      );
      final whatsapp = tester.widget<IconButton>(
        find.ancestor(
          of: find.byType(FaIcon),
          matching: find.byType(IconButton),
        ),
      );

      expect(call.onPressed, isNull);
      expect(whatsapp.onPressed, isNull);
    });

    testWidgets('tapping a disabled action does not throw', (tester) async {
      useDesignSurface(tester);
      await tester.pumpWidget(wrapWidget(const UserAddressCard()));

      await tester.tap(find.byIcon(Icons.call));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}