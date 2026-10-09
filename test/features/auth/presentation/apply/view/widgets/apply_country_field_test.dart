import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/country_entity.dart';
import 'package:driver_app/features/auth/presentation/apply/view/widgets/apply_country_field.dart';

void main() {
  const sampleCountries = [
    CountryEntity(isoCode: 'EG', name: 'Egypt', phoneCode: '20', flag: '🇪🇬'),
    CountryEntity(
      isoCode: 'SA',
      name: 'Saudi Arabia',
      phoneCode: '966',
      flag: '🇸🇦',
    ),
  ];

  Widget buildWidget({
    required List<CountryEntity> countries,
    CountryEntity? selectedCountry,
    ValueChanged<CountryEntity>? onCountrySelected,
  }) {
    return ScreenUtilPlusInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        home: Scaffold(
          body: ApplyCountryField(
            countries: countries,
            selectedCountry: selectedCountry,
            onCountrySelected: onCountrySelected,
          ),
        ),
      ),
    );
  }

  testWidgets('renders ApplyCountryField with countries and selected item', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildWidget(
        countries: sampleCountries,
        selectedCountry: sampleCountries.first,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.country), findsWidgets);
    expect(find.text('🇪🇬 +20'), findsOneWidget);
  });

  testWidgets('opens dropdown and selecting a country calls callback', (
    tester,
  ) async {
    CountryEntity? selected;

    await tester.pumpWidget(
      buildWidget(
        countries: sampleCountries,
        selectedCountry: sampleCountries.first,
        onCountrySelected: (c) => selected = c,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(find.text('Saudi Arabia'), findsOneWidget);

    await tester.tap(find.text('Saudi Arabia'));
    await tester.pumpAndSettle();

    expect(selected, sampleCountries[1]);
  });
}
