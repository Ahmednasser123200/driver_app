import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/pickup_location/domain/entities/driving_route.dart';
import 'package:driver_app/features/pickup_location/domain/entities/map_location.dart';
import 'package:driver_app/features/pickup_location/presentation/view/pickup_location_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../helpers/widget_harness.dart';

void main() {
  testWidgets('renders the localized customer and store details', (
    tester,
  ) async {
    useDesignSurface(tester);

    await tester.pumpWidget(
      wrapWidget(
        const PickupLocationBody(
          pickupLocation: LatLng(30.0444, 31.2357),
          userLocation: LatLng(30.0398, 31.2302),
        ),
      ),
    );

    expect(find.text('Nour mohamed'), findsOneWidget);
    expect(find.text('Flowery store'), findsOneWidget);
    expect(find.text('20th st, Sheikh Zayed, Giza'), findsNWidgets(2));
  });

  testWidgets('shows a loading indicator while the route is loading', (
    tester,
  ) async {
    useDesignSurface(tester);

    await tester.pumpWidget(
      wrapWidget(
        const PickupLocationBody(
          pickupLocation: LatLng(30.0444, 31.2357),
          userLocation: LatLng(30.0398, 31.2302),
          isLoadingRoute: true,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('draws the driving route with the centralized route color', (
    tester,
  ) async {
    useDesignSurface(tester);

    await tester.pumpWidget(
      wrapWidget(
        PickupLocationBody(
          pickupLocation: const LatLng(30.0444, 31.2357),
          userLocation: const LatLng(30.0398, 31.2302),
          route: const DrivingRoute(
            points: [
              MapLocation(latitude: 30.0444, longitude: 31.2357),
              MapLocation(latitude: 30.0398, longitude: 31.2302),
            ],
            distanceMeters: 1842.7,
            durationSeconds: 312.4,
          ),
        ),
      ),
    );

    final map = tester.widget<GoogleMap>(find.byType(GoogleMap));

    expect(map.polylines, hasLength(1));
    expect(map.polylines.single.color, AppColors.primary);
    expect(map.polylines.single.points, hasLength(2));
  });
}
