import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/pickup_location/domain/entities/driving_route.dart';
import 'package:driver_app/features/pickup_location/presentation/utils/map_helper.dart';
import 'package:driver_app/features/pickup_location/presentation/widgets/location_addresses_panel.dart';
import 'package:driver_app/features/pickup_location/presentation/widgets/pickup_map.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
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
    final l10n = AppLocalizations.of(context)!;

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
            Expanded(
              flex: 4,
              child: LocationAddressesPanel(
                userName: l10n.customerName,
                userAddress: l10n.address,
                storeName: l10n.floweryStore,
                storeAddress: l10n.address,
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
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.r),
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
