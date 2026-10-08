import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/country_entity.dart';

import 'apply_dropdown_field.dart';

class ApplyCountryField extends StatelessWidget {
  final List<CountryEntity> countries;
  final CountryEntity? selectedCountry;
  final ValueChanged<CountryEntity>? onCountrySelected;

  const ApplyCountryField({
    super.key,
    required this.countries,
    this.selectedCountry,
    this.onCountrySelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = countries.map((country) {
      return ApplyDropdownItem<CountryEntity>(
        value: country,
        label: country.name,
        fieldText: '${country.flag} +${country.phoneCode}',
        leading: Text(country.flag, style: TextStyle(fontSize: 20.sp)),
      );
    }).toList();

    return ApplyDropdownField<CountryEntity>(
      label: AppStrings.country,
      hint: AppStrings.country,
      items: items,
      selectedValue: selectedCountry,
      onChanged: onCountrySelected,
      searchable: true,
    );
  }
}