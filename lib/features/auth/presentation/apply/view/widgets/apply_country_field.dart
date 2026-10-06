import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:driver_app/core/constants/app_strings/app_strings.dart';

import 'apply_dropdown_field.dart';

class ApplyCountryField extends StatelessWidget {
  final ValueNotifier<Country> countryNotifier;
  final List<Country>? countries;

  const ApplyCountryField({
    super.key,
    required this.countryNotifier,
    this.countries,
  });

  static List<ApplyDropdownItem<Country>>? _cachedItems;

  static List<ApplyDropdownItem<Country>> _buildItems(List<Country> list) {
    return list.map((country) {
      return ApplyDropdownItem<Country>(
        value: country,
        label: country.name,
        fieldText: '${country.flagEmoji} +${country.phoneCode}',
        leading: Text(country.flagEmoji, style: TextStyle(fontSize: 20.sp)),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<ApplyDropdownItem<Country>> items;
    if (countries != null) {
      items = _buildItems(countries!);
    } else {
      items = _cachedItems ??= _buildItems(CountryService().getAll());
    }

    return ApplyDropdownField<Country>(
      label: AppStrings.country,
      hint: AppStrings.country,
      items: items,
      valueNotifier: countryNotifier,
      searchable: true,
    );
  }
}