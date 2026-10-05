import 'package:driver_app/core/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/widget_harness.dart';

void main() {
  Widget subject({Widget child = const SizedBox.shrink()}) =>
      wrapWidget(child);

  group('variants', () {
    testWidgets('filled variant builds an ElevatedButton', (tester) async {
      await tester.pumpWidget(
        subject(child: const CustomButton(label: 'Confirm')),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('outlined variant builds an OutlinedButton', (tester) async {
      await tester.pumpWidget(
        subject(
          child: const CustomButton(
            label: 'Cancel',
            variant: ButtonVariant.outlined,
          ),
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });

  group('content', () {
    testWidgets('renders the label', (tester) async {
      await tester.pumpWidget(
        subject(child: const CustomButton(label: 'Confirm order')),
      );

      expect(find.text('Confirm order'), findsOneWidget);
    });

    testWidgets('renders the icon before the label when provided', (tester) async {
      await tester.pumpWidget(
        subject(
          child: const CustomButton(
            label: 'Call',
            icon: Icon(Icons.phone),
          ),
        ),
      );

      expect(find.byIcon(Icons.phone), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
    });

    testWidgets('renders no icon by default', (tester) async {
      await tester.pumpWidget(subject(child: const CustomButton(label: 'Call')));

      expect(find.byIcon(Icons.phone), findsNothing);
    });
  });

  group('interaction', () {
    testWidgets('invokes onPressed when tapped', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        subject(
          child: CustomButton(label: 'Confirm', onPressed: () => taps++),
        ),
      );

      await tester.tap(find.text('Confirm'));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('does nothing when onPressed is null', (tester) async {
      await tester.pumpWidget(subject(child: const CustomButton(label: 'Confirm')));

      await tester.tap(find.text('Confirm'));
      await tester.pump();

      expect(find.byType(ElevatedButton), findsOneWidget);
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('does nothing when enabled is false', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        subject(
          child: CustomButton(
            label: 'Confirm',
            enabled: false,
            onPressed: () => taps++,
          ),
        ),
      );

      await tester.tap(find.text('Confirm'));
      await tester.pump();

      expect(taps, 0);
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });

  group('loading state', () {
    testWidgets('shows a progress indicator instead of the label', (tester) async {
      await tester.pumpWidget(
        subject(child: const CustomButton(label: 'Confirm', isLoading: true)),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Confirm'), findsNothing);
    });

    testWidgets('blocks taps while loading', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        subject(
          child: CustomButton(
            label: 'Confirm',
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      );

      await tester.tap(find.byType(CircularProgressIndicator));
      await tester.pump();

      expect(taps, 0);
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('restores the label once loading finishes', (tester) async {
      Widget build({required bool isLoading}) => subject(
        child: CustomButton(
          label: 'Confirm',
          isLoading: isLoading,
          onPressed: () {},
        ),
      );

      await tester.pumpWidget(build(isLoading: true));
      expect(find.text('Confirm'), findsNothing);

      await tester.pumpWidget(build(isLoading: false));
      await tester.pumpAndSettle();

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('hides the icon while loading', (tester) async {
      await tester.pumpWidget(
        subject(
          child: const CustomButton(
            label: 'Confirm',
            isLoading: true,
            icon: Icon(Icons.phone),
          ),
        ),
      );

      expect(find.byIcon(Icons.phone), findsNothing);
    });
  });

  group('sizing', () {
    testWidgets('uses the custom width and height when provided', (tester) async {
      await tester.pumpWidget(
        subject(
          child: const CustomButton(label: 'Confirm', width: 300, height: 60),
        ),
      );

      final box = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(CustomButton),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      expect(box.width, 300);
      expect(box.height, 60);
    });

    testWidgets('falls back to the design defaults', (tester) async {
      await tester.pumpWidget(subject(child: const CustomButton(label: 'Confirm')));

      final box = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(CustomButton),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      expect(box.width, isNotNull);
      expect(box.height, isNotNull);
    });
  });
}