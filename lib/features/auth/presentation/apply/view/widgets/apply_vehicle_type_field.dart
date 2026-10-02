import 'package:flutter/material.dart';

import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/applications_entity.dart';

import 'apply_dropdown_field.dart';

class ApplyVehicleTypeField extends StatelessWidget {
  final ValueNotifier<VehicleType> vehicleTypeNotifier;

  const ApplyVehicleTypeField({super.key, required this.vehicleTypeNotifier});

  @override
  Widget build(BuildContext context) {
    final items = VehicleType.values.map((type) {
      return ApplyDropdownItem<VehicleType>(
        value: type,
        label: type.apiValue,
      );
    }).toList();

    return ApplyDropdownField<VehicleType>(
      label: AppStrings.vehicleType,
      hint: AppStrings.vehicleType,
      items: items,
      valueNotifier: vehicleTypeNotifier,
      searchable: false,
    );
  }
}
