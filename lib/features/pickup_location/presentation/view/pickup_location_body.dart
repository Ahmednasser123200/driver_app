import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/pickup_location/domain/entities/driving_route.dart';
import 'package:driver_app/features/pickup_location/presentation/utils/map_helper.dart';
import 'package:driver_app/features/pickup_location/presentation/widgets/location_addresses_panel.dart';
import 'package:driver_app/features/pickup_location/presentation/widgets/pickup_map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickupLocationBody extends StatelessWidget {
  const PickupLocationBody({
    super.key,
    required this.pickupLocation,
    required this.userLocation,
    this.driverLocation,
    this.route,
    this.isLoadingRoute = false,
  });

  final LatLng pickupLocation;
  final LatLng userLocation;
  final LatLng? driverLocation;

  /// The driving route between the pickup and the customer location.
  final DrivingRoute? route;

  final bool isLoadingRoute;

  @override
  Widget build(BuildContext context) {
    final routePoints =
        route?.points.map((point) => point.toLatLng()).toList() ?? const [];

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              flex: 6,
              child: PickupMap(
                pickupLocation: pickupLocation,
                userLocation: userLocation,
                driverLocation: driverLocation,
                routePoints: routePoints,
              ),
            ),
            const Expanded(
              flex: 4,
              child: LocationAddressesPanel(
                userName: 'Nour mohamed',
                userAddress: '20th st, Sheikh Zayed, Giza',
                storeName: 'Flowery store',
                storeAddress: '20th st, Sheikh Zayed, Giza',
              ),
            ),
          ],
        ),
        if (isLoadingRoute)
          const Positioned(top: 16, right: 16, child: _RouteLoadingIndicator()),
      ],
    );
  }
}

class _RouteLoadingIndicator extends StatelessWidget {
  const _RouteLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
