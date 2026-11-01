import 'package:driver_app/features/delivery_map/presentation/utils/map_marker_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapMarkerGenerator', () {
    test('createPillMarker runs without throwing', () async {
      final marker = await MapMarkerGenerator.createPillMarker(
        label: 'Your location',
        icon: Icons.navigation,
      );

      expect(marker, isNotNull);
    });
  });
}
