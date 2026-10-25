import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:driver_app/features/pickup_location/presentation/utils/map_helper.dart';
import 'package:driver_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickupMap extends StatefulWidget {
  const PickupMap({
    super.key,
    required this.pickupLocation,
    required this.userLocation,
    this.driverLocation,
    this.routePoints = const [],
  });

  final LatLng pickupLocation;
  final LatLng userLocation;
  final LatLng? driverLocation;

  /// The coordinates of the driving route, empty when no route is available.
  final List<LatLng> routePoints;

  static const Color routeColor = AppColors.primary;

  @override
  State<PickupMap> createState() => _PickupMapState();
}

class _PickupMapState extends State<PickupMap> {
  GoogleMapController? _mapController;

  @override
  void didUpdateWidget(covariant PickupMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newLocation = widget.driverLocation;

    final hasNewRoute =
        widget.routePoints.isNotEmpty && oldWidget.routePoints.isEmpty;

    if (newLocation != null && newLocation != oldWidget.driverLocation) {
      _mapController?.animateCamera(CameraUpdate.newLatLng(newLocation));
    } else if (hasNewRoute) {
      _animateToRoute();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _animateToRoute() {
    final controller = _mapController;
    final points = widget.routePoints;

    if (controller == null || points.isEmpty) return;

    final bounds = buildRouteBounds(points);

    if (bounds == null) return;

    final isSinglePoint =
        bounds.southwest.latitude == bounds.northeast.latitude &&
        bounds.southwest.longitude == bounds.northeast.longitude;

    if (isSinglePoint) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(points.first, 14));
      return;
    }

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('pickup'),
        position: widget.pickupLocation,
        infoWindow: InfoWindow(title: l10n.pickupAddress),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      ),
      Marker(
        markerId: const MarkerId('user'),
        position: widget.userLocation,
        infoWindow: InfoWindow(title: l10n.userAddress),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      if (widget.driverLocation != null)
        Marker(
          markerId: const MarkerId('driver'),
          position: widget.driverLocation!,
          infoWindow: InfoWindow(title: l10n.yourLocation),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
    };

    final polylines = <Polyline>{
      if (widget.routePoints.isNotEmpty)
        Polyline(
          polylineId: const PolylineId('delivery_route'),
          points: widget.routePoints,
          color: PickupMap.routeColor,
          width: 4,
        ),
    };

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.driverLocation ?? widget.pickupLocation,
        zoom: 14,
      ),
      onMapCreated: (controller) {
        _mapController = controller;

        final driverLocation = widget.driverLocation;

        if (driverLocation != null) {
          controller.animateCamera(
            CameraUpdate.newLatLngZoom(driverLocation, 15),
          );
        } else if (widget.routePoints.isNotEmpty) {
          _animateToRoute();
        }
      },
      markers: markers,
      polylines: polylines,
      mapType: MapType.normal,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}
