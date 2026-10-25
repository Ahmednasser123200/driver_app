import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/core/shared/widgets/custom_text_form_field.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';

void main() {
  Widget buildTestWidget({required Widget child}) {
    return ScreenUtilPlusInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Padding(padding: const EdgeInsets.all(16.0), child: child),
        ),
      ),
    );
  }

  group('CustomTextFormField - Password obscureText toggle', () {
    testWidgets(
      'starts with obscureText true and toggles visibility on icon tap',
      (tester) async {
        final controller = TextEditingController(text: 'secretPassword123');

        await tester.pumpWidget(
          buildTestWidget(
            child: CustomTextFormField(
              label: 'Password',
              controller: controller,
              obscureText: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initially obscured
        TextField textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.obscureText, isTrue);
        expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
        expect(find.byIcon(Icons.visibility_outlined), findsNothing);

        // Tap suffix icon to unmask password
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Now revealed
        textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.obscureText, isFalse);
        expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

        // Tap again to obscure password
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Masked again
        textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.obscureText, isTrue);
        expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
        expect(find.byIcon(Icons.visibility_outlined), findsNothing);
      },
    );

    testWidgets('renders plain text field when obscureText is false', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'John');

      await tester.pumpWidget(
        buildTestWidget(
          child: CustomTextFormField(
            label: 'First Name',
            controller: controller,
            obscureText: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isFalse);
      expect(find.byType(IconButton), findsNothing);
    });
  });
}
