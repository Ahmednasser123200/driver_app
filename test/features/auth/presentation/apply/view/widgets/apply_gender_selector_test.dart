import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/auth/presentation/apply/view/widgets/apply_gender_selector.dart';

void main() {
  testWidgets('renders gender options and selecting triggers callback', (
    tester,
  ) async {
    String? chosenGender;

    await tester.pumpWidget(
      ScreenUtilPlusInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: ApplyGenderSelector(
              selectedGender: 'Male',
              onGenderChanged: (val) => chosenGender = val,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.gender), findsOneWidget);
    expect(find.text(AppStrings.female), findsOneWidget);
    expect(find.text(AppStrings.male), findsOneWidget);

    await tester.tap(find.text(AppStrings.female));
    await tester.pumpAndSettle();

    expect(chosenGender, 'Female');

    await tester.tap(find.text(AppStrings.male));
    await tester.pumpAndSettle();

    expect(chosenGender, 'Male');
  });
}
