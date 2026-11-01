import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driver_app/features/auth/presentation/apply/view/widgets/apply_dropdown_field.dart';

void main() {
  Widget buildTestWidget({
    String? selectedValue,
    ValueChanged<String>? onChanged,
    ValueNotifier<String>? valueNotifier,
    bool searchable = true,
  }) {
    return ScreenUtilPlusInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ApplyDropdownField<String>(
                label: 'Test Dropdown',
                hint: 'Select an option',
                searchable: searchable,
                selectedValue: selectedValue,
                onChanged: onChanged,
                valueNotifier: valueNotifier,
                items: const [
                  ApplyDropdownItem(value: 'opt1', label: 'Option One'),
                  ApplyDropdownItem(value: 'opt2', label: 'Option Two'),
                  ApplyDropdownItem(value: 'opt3', label: 'Option Three'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  testWidgets('renders ApplyDropdownField with label and hint', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Test Dropdown'), findsOneWidget);
    expect(find.text('Select an option'), findsOneWidget);
  });

  testWidgets(
    'tapping suffix icon opens overlay and selecting item updates value via onChanged',
    (tester) async {
      String? chosen;
      await tester.pumpWidget(
        buildTestWidget(onChanged: (val) => chosen = val),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.text('Option One'), findsOneWidget);
      expect(find.text('Option Two'), findsOneWidget);
      expect(find.text('Option Three'), findsOneWidget);

      await tester.tap(find.text('Option Two'));
      await tester.pumpAndSettle();

      expect(chosen, 'opt2');
      expect(find.text('Option Two'), findsOneWidget);
    },
  );

  testWidgets(
    'typing query in searchable dropdown filters items and shows no results if unmatched',
    (tester) async {
      await tester.pumpWidget(buildTestWidget(searchable: true));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'Three');
      await tester.pumpAndSettle();

      expect(find.text('Option Three'), findsWidgets);
      expect(find.text('Option One'), findsNothing);

      await tester.enterText(find.byType(TextFormField), 'XYZ');
      await tester.pumpAndSettle();

      expect(find.text('No results'), findsOneWidget);
    },
  );

  testWidgets('tapping outside closes menu', (tester) async {
    await tester.pumpWidget(buildTestWidget(selectedValue: 'opt1'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    expect(find.text('Option Two'), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.text('Option Two'), findsNothing);
  });
}
