import 'package:flutter/material.dart';

import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/vehicle_type_entity.dart';

import 'apply_dropdown_field.dart';

class ApplyVehicleTypeField extends StatelessWidget {
  final List<VehicleTypeEntity> vehicleTypes;
  final VehicleTypeEntity? selectedVehicleType;
  final ValueChanged<VehicleTypeEntity>? onVehicleTypeSelected;

  const ApplyVehicleTypeField({
    super.key,
    required this.vehicleTypes,
    this.selectedVehicleType,
    this.onVehicleTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = vehicleTypes.map((type) {
      return ApplyDropdownItem<VehicleTypeEntity>(
        value: type,
        label: type.name,
      );
    }).toList();

    return ApplyDropdownField<VehicleTypeEntity>(
      label: AppStrings.vehicleType,
      hint: AppStrings.vehicleType,
      items: items,
      selectedValue: selectedVehicleType,
      onChanged: onVehicleTypeSelected,
      searchable: false,
    );
  }
}
