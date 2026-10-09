import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driver_app/core/constants/app_strings/app_strings.dart';
import 'package:driver_app/features/auth/domain/entities/apply_entity/vehicle_type_entity.dart';
import 'package:driver_app/features/auth/presentation/apply/view/widgets/apply_vehicle_type_field.dart';

void main() {
  const sampleVehicleTypes = [
    VehicleTypeEntity(id: '1', name: 'Car'),
    VehicleTypeEntity(id: '2', name: 'Motorcycle'),
  ];

  Widget buildWidget({
    required List<VehicleTypeEntity> vehicleTypes,
    VehicleTypeEntity? selectedVehicleType,
    ValueChanged<VehicleTypeEntity>? onVehicleTypeSelected,
  }) {
    return ScreenUtilPlusInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        home: Scaffold(
          body: ApplyVehicleTypeField(
            vehicleTypes: vehicleTypes,
            selectedVehicleType: selectedVehicleType,
            onVehicleTypeSelected: onVehicleTypeSelected,
          ),
        ),
      ),
    );
  }

  testWidgets(
    'renders ApplyVehicleTypeField with vehicle types and selected value',
    (tester) async {
      await tester.pumpWidget(
        buildWidget(
          vehicleTypes: sampleVehicleTypes,
          selectedVehicleType: sampleVehicleTypes.first,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.vehicleType), findsWidgets);
      expect(find.text('Car'), findsOneWidget);
    },
  );

  testWidgets('opens dropdown and selecting vehicle type calls callback', (
    tester,
  ) async {
    VehicleTypeEntity? selected;

    await tester.pumpWidget(
      buildWidget(
        vehicleTypes: sampleVehicleTypes,
        selectedVehicleType: sampleVehicleTypes.first,
        onVehicleTypeSelected: (v) => selected = v,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(find.text('Motorcycle'), findsOneWidget);

    await tester.tap(find.text('Motorcycle'));
    await tester.pumpAndSettle();

    expect(selected, sampleVehicleTypes[1]);
  });
}
